open Printf
open Lwt

let http_post url body =
  Cohttp_lwt_unix.Client.call
    ~body ~chunked:false `POST (Uri.of_string url) >>= function
  | None -> failwith "no response"
  | Some (resp, body) ->
      let status = Cohttp_lwt_unix.Response.status resp in
      let code = Cohttp.Code.code_of_status status in
      let resp_body = Cohttp_lwt_body.string_of_body body in
      return (code, resp_body)

let send message =
  let url, body = Messages.Send.make_request message in
  http_post url body >>= fun (code, body) ->
  return (Messages.Send.parse_response code body)

let print_success msg b =
  printf "%012s %s\n%!" msg (if b then "OK" else "ERROR")

let random_id =
  Random.self_init ();
  fun () -> sprintf "%08x" (Random.int (1 lsl 30 - 1))

let test1 email_addr () =
  let credentials = Keys.get () in
  let id = random_id () in
  let api_key =
    match credentials.Keys_t.sendgrid_key with
        None -> failwith "Missing Sendgrid key"
      | Some x -> x
  in
  Sendgrid.send_mail
    ~api_user: credentials.Keys_t.sendgrid_user
    ~api_key
    ~from: email_addr
    ~fromname: "Tester Sending"
    ~to_: email_addr
    ~toname: "Tester Receiving"
    ~subject: (sprintf "Welcome! [test %s]" id)
    ~text: "Welcome to SendGrid!"
    ~html: "<html><body><p>Welcome to <b>SendGrid</b>!</p></body></html>"
    ~category: ["test"]
    ()
    >>= print_success (sprintf "test1 [%s]" id)

let tests = [
  "test1", test1 email_addr
]

let run l =
  Lwt_list.map_s (fun (name, f) ->
    printf "TEST %n%!" name;

let main ~offset =
  Log.level := `Debug;
  let email_addr =
    match Cmdline.parse
      ~offset
      ~anon_count:1
      ~usage_msg:"Usage: test_sendgrid EMAIL" []
    with
        [s] -> s
      | _ -> assert false
  in
  Lwt_main.run (Lwt_list.iter_s (fun f -> f ()) tests)
