(*
  See API specification at
  https://mandrillapp.com/api/docs/messages.JSON.html#method-send
*)

open Printf
open Mandrill_t

exception Api_error of string

let base_url = "https://mandrillapp.com/api/1.0"

module Messages = struct

  module Send = struct

    let url = base_url ^ "/messages/send.json"

    let make_request message =
      let body = Mandrill_j.string_of_message message in
      (url, body)

    let parse_response status_code body =
      match status_code with
      | 200 ->
          (try
            Success (Mandrill_j.messages_send_success_list_of_string body)
           with _ ->
            raise (Api_error ("Unparsable ok response body: " ^ body))
          )
      | _ ->
          (try
            Error (status_code, Mandrill_j.messages_send_error_of_string body)
           with _ ->
            raise (Api_error ("Unparsable error response body: " ^ body))
          )

  end
end
