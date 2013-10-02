type t = float

let to_string t =
  let open Unix in
  let tm = gmtime t in
  Printf.sprintf "%04d-%02d-%02d %02d:%02d:%02d"
    (1900 + tm.tm_year)
    (1 + tm.tm_mon)
    tm.tm_mday
    tm.tm_hour
    tm.tm_min
    tm.tm_sec

let of_string t =
  failwith "Mandrill_date.unwrap: not implemented"

let wrap = of_string
let unwrap = to_string
