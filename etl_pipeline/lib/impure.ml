open Custom_types

let parse_status = function
  | "Pending" -> Ok Pending
  | "Complete" -> Ok Complete
  | "Cancelled" -> Ok Cancelled
  | _ -> Error Unknown_status

let parse_origin = function
  | "O" -> Ok Online
  | "P" -> Ok InPerson
  | _ -> Error Unknown_origin

let parse_id raw_id =
  raw_id
  |> int_of_string
  (* |> Option.to_result ~none:`Invalid_id *)

let get_two_digits str pos =
  String.sub str pos 2
  |> int_of_string

(* let parse_datetime dt_str : string =
  let* year =
    Year (String.sub dt_str 0 4 |> int_of_string)
  in
  let* month =
    Month (get_two_digits dt_str 6)
  in
  let* day =
    Day (get_two_digits dt_str 9)
  in
  let* hour =
    Hour (get_two_digits dt_str 12)
  in 
  let* minutes = 
    Minutes (get_two_digits dt_str 15)
  in
  let* seconds =
    Seconds (get_two_digits datetime_str 18)
  in 
  Ok (year , month , day , hour , minutes , seconds) *)

  let parse_datetime dt_str =
      let year   = Year (String.sub dt_str 0 4 |> int_of_string) in
      let month  = Month (String.sub dt_str 5 2 |> int_of_string) in
      let day    = Day (String.sub dt_str 8 2 |> int_of_string) in
      let hour   = Hour (String.sub dt_str 11 2 |> int_of_string) in
      let minutes= Minutes (String.sub dt_str 14 2 |> int_of_string) in
      let seconds= Seconds (String.sub dt_str 17 2 |> int_of_string) in
      (year, month, day, hour, minutes, seconds)

(* let parse_datetime datetime_str : string =
  (Year String.sub datetime_str 0 4 |> int_of_string, Month get_two_digits datetime_str 6, Day get_two_digits datetime_str 9, Hour get_two_digits datetime_str 12, Minutes get_two_digits datetime_str 15, Seconds get_two_digits datetime_str 18) *)

let parse_row row =
  let id =
    Csv.Row.find row "id" |> parse_id
  in
  let client_id =
    Csv.Row.find row "client_id" |> parse_id
  in
  let order_date =
    Csv.Row.find row "order_date" |> parse_datetime
  in
  let status =
  Csv.Row.find row "status" |> parse_status
  in
  let origin =
  Csv.Row.find row "origin" |> parse_origin
  in
  Ok { id; client_id; order_date; status; origin}


let parse_order csv_str =
  csv_str
  |> Csv.of_string ~has_header:true
  |> Csv.Rows.input_all
  |> List.map parse_row
  
    
let load_orders () = Csv.load "data/raw/order.csv"  
