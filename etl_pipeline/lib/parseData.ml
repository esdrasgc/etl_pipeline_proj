(** This module contains functions for parsing data between different formats *)
open CustomTypes

(** Parses a string representation of order status into its enum value
    @param status_str String representation of the status
    @return The corresponding order_status value
*)
let parse_status = function
  | "Pending" -> Pending
  | "Complete" -> Complete
  | "Cancelled" -> Cancelled
  | _ -> Unknown_status

(** Parses a string representation of order origin into its enum value
    @param origin_str String representation of the origin
    @return The corresponding order_origin value
*)
let parse_origin = function
  | "O" -> Online
  | "P" -> InPerson
  | _ -> Unknown_origin

(** Parses a string representation of datetime into a structured datetime tuple
    @param dt_str String representation of datetime in format "YYYY-MM-DD HH:MM:SS"
    @return A datetime tuple containing all components
*)
let parse_datetime dt_str =
  let year   = Year (String.sub dt_str 0 4 |> int_of_string) in
  let month  = Month (String.sub dt_str 5 2 |> int_of_string) in
  let day    = Day (String.sub dt_str 8 2 |> int_of_string) in
  let hour   = Hour (String.sub dt_str 11 2 |> int_of_string) in
  let minutes= Minutes (String.sub dt_str 14 2 |> int_of_string) in
  let seconds= Seconds (String.sub dt_str 17 2 |> int_of_string) in
  (year, month, day, hour, minutes, seconds)

(** Updates an order record with a field from CSV data
    @param obj A tuple containing column name and value
    @param old_record Current state of the order record
    @return Updated order record with the new field value
*)
let create_updated_record_order obj old_record : order =
  match obj with (column, value) ->
    match column with 
    | "id" -> {old_record with id = int_of_string value}
    | "client_id" -> {old_record with client_id = int_of_string value}
    | "order_date" -> {old_record with order_date = parse_datetime value}
    | "status" -> {old_record with status = parse_status value}
    | "origin" -> {old_record with origin = parse_origin value}
    | _ -> old_record

(** Parses a row of CSV data into an order record
    @param row List of column-value pairs from CSV
    @return A complete order record
*)
let parse_row row : order =
  let initial_record = {
    id = -1;
    client_id = -1;
    order_date = (Year 0, Month 0, Day 0, Hour 0, Minutes 0, Seconds 0);
    status = Unknown_status;
    origin = Unknown_origin
  } in
  List.fold_left (fun acc obj -> create_updated_record_order obj acc) initial_record row

(** Parses a CSV table into a list of order records
    @param csv_t CSV table with headers and data rows
    @return List of parsed order records
*)
let parse_order csv_t : order list =
  let header, data = match csv_t with h :: d -> h, d | [] -> ([], []) in
  let data_associated = Csv.associate header data in
  List.map parse_row data_associated

(** Updates an order item record with a field from CSV data
    @param obj A tuple containing column name and value
    @param old_record Current state of the order item record
    @return Updated order item record with the new field value
*)
let create_updated_record_order_item obj old_record : order_item =
  match obj with (column, value) ->
    match column with 
    | "order_id" -> {old_record with order_id = int_of_string value}
    | "product_id" -> {old_record with product_id = int_of_string value}
    | "quantity" -> {old_record with quantity = int_of_string value}
    | "price" -> {old_record with price = float_of_string value}
    | "tax" -> {old_record with tax = float_of_string value}
    | _ -> old_record

(** Parses a row of CSV data into an order item record
    @param row List of column-value pairs from CSV
    @return A complete order item record
*)
let parse_row_order_item row : order_item =
  let initial_record = {
    order_id = -1;
    product_id = -1;
    quantity = -1;
    price = -1.0;
    tax = -1.0;
  } in
  List.fold_left (fun acc obj -> create_updated_record_order_item obj acc) initial_record row

(** Parses a CSV table into a list of order item records
    @param csv_t CSV table with headers and data rows
    @return List of parsed order item records
*)
let parse_order_item csv_t : order_item list =
  let header, data = match csv_t with h :: d -> h, d | [] -> ([], []) in
  let data_associated = Csv.associate header data in
  List.map parse_row_order_item data_associated

(** Converts a list of aggregated order info records to CSV format
    @param agg_order List of aggregated order information
    @return CSV table with headers and data ready to be saved
*)
let parse_agg_order_to_csv (agg_order : agg_order_info list) : Csv.t =
  let header = ["order_id"; "total_amount"; "total_taxes";] in
  let data = List.map (fun agg_info ->
    [
      string_of_int agg_info.order_id_;
      string_of_float agg_info.total_amount;
      string_of_float agg_info.total_taxes;
    ]
  ) agg_order in
  header :: data