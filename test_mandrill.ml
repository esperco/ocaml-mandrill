open Printf
open Lwt

let http_post url body =
  Cohttp_lwt_unix.Client.call
    ?body:(Cohttp_lwt_body.body_of_string body)
    ~chunked:false`POST (Uri.of_string url) >>= function
  | None -> failwith "no response"
  | Some (resp, body) ->
      let status = Cohttp_lwt_unix.Response.status resp in
      let code = Cohttp.Code.code_of_status status in
      Cohttp_lwt_body.string_of_body body >>= fun resp_body ->
      return (code, resp_body)

let send send_req =
  let url, body = Mandrill.Messages.Send.make_request send_req in
  http_post url body >>= fun (code, body) ->
  return (Mandrill.Messages.Send.parse_response code body)

let random_id =
  Random.self_init ();
  fun () -> sprintf "%08x" (Random.int (1 lsl 30 - 1))

let make_default_message ~subject ~html conf =
  let open Mandrill_t in
  Mandrill_v.create_message
    ~from_name: conf.test_sender_name
    ~from_email: conf.test_sender_email
    ~to_: [ { rec_name = Some conf.test_recipient_name;
              rec_email = conf.test_recipient_email } ]
    ~subject
    ~html
    ()

let make_default_request ~subject ~html conf =
  let open Mandrill_t in
  Mandrill_v.create_messages_send_request
    ~key: conf.test_key
    ~message: (make_default_message ~subject ~html conf)
    ()

let wrap_html s =
  "<html><body><p>" ^ s ^ "</p></body></html>"

let test_simple conf =
  send (make_default_request
          ~subject:"Simple test"
          ~html:(wrap_html "Simple.")
          conf)
  >>= function
    | Mandrill_t.Success _ -> return true
    | Mandrill_t.Error _ -> return false

let tests = [
  "simple", test_simple
]

let print_test_results l =
  List.iter (fun (name, success) ->
    printf "%-12s %s\n" name (if success then "OK" else "ERROR")
  ) l;
  flush stdout

let run conf l =
  Lwt_list.map_s (fun (name, f) ->
    printf "TEST %s\n%!" name;
    catch
      (fun () -> f conf)
      (fun e ->
        eprintf "Failed with exception: %s\n%!"
          (Printexc.to_string e);
        return false
      )
    >>= fun success ->
    return (name, success)
  ) l

let load_conf file =
  Ag_util.Json.from_file Mandrill_j.read_testconf file

let main () =
  let conf_file = ref "test.conf" in
  let options = [
    "-conf", Arg.Set_string conf_file,
    "<file>  JSON config file (see mandrill.atd)";
  ] in
  let anon_fun s = failwith ("Bad command-line argument " ^ s) in
  let err_msg = "Options:\n" in
  Arg.parse options anon_fun err_msg;
  let conf = load_conf !conf_file in
  let test_results = Lwt_main.run (run conf tests) in
  print_test_results test_results

let () = main ()
