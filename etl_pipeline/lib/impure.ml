open Custom_types

(* let parse_id raw_id =
  raw_id
  |> int_of_string *)
  (* |> Option.to_result ~none:`Invalid_id *)

let parse_datetime dt_str =
    let year   = Year (String.sub dt_str 0 4 |> int_of_string) in
    let month  = Month (String.sub dt_str 5 2 |> int_of_string) in
    let day    = Day (String.sub dt_str 8 2 |> int_of_string) in
    let hour   = Hour (String.sub dt_str 11 2 |> int_of_string) in
    let minutes= Minutes (String.sub dt_str 14 2 |> int_of_string) in
    let seconds= Seconds (String.sub dt_str 17 2 |> int_of_string) in
    (year, month, day, hour, minutes, seconds)

let create_updated_record_order obj old_record =
  match obj with (column, value) ->
    match column with 
    | "id" -> {old_record with id = int_of_string value}
    | "client_id" -> {old_record with client_id = int_of_string value}
    | "order_date" -> {old_record with order_date = parse_datetime value}
    | "status" -> {old_record with status = Pure.parse_status value}
    | "origin" -> {old_record with origin = Pure.parse_origin value}
    | _ -> old_record

let parse_row row : (string * string) list =
  let rec parse_row_acumulated remaining_objs actual_record =
    match remaining_objs with
    | [] -> actual_record
    | h::t -> create_updated_record_order h (parse_row_acumulated t actual_record)
  in
  parse_row_acumulated row {id = -1;client_id = -1; order_date = (Year 0, Month 0, Day 0, Hour 0, Minutes 0, Seconds 0); status = Unknown_status; origin = Unknown_origin}

let parse_order csv_t : Csv.t =
  let header, data = match csv_t with h :: d -> h, d | [] -> ([], []) in
  let data_associated = Csv.associate header data in
  data_associated 
  |> List.map parse_row
  
let load_orders () = Csv.load "data/raw/order.csv"  