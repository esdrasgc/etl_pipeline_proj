open Custom_types

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

let parse_row row : order =
  let initial_record = {
    id = -1;
    client_id = -1;
    order_date = (Year 0, Month 0, Day 0, Hour 0, Minutes 0, Seconds 0);
    status = Unknown_status;
    origin = Unknown_origin
  } in
  List.fold_left (fun acc obj -> create_updated_record_order obj acc) initial_record row

let parse_order csv_t : order list =
  let header, data = match csv_t with h :: d -> h, d | [] -> ([], []) in
  let data_associated = Csv.associate header data in
  List.map parse_row data_associated
  
let load_orders () = Csv.load "data/raw/order.csv"