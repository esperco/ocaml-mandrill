exception Api_error of string

module Messages : sig
  module Send : sig
    val make_request : Mandrill_t.message -> (string * string)
      (* Return URL and body suitable for an HTTP POST request *)

    val parse_response :
      int -> string -> Mandrill_t.messages_send_response
      (* Interpret the HTTP response status and body *)
  end
end
