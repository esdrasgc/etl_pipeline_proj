(** This module contains functions for transforming order data *)
open CustomTypes

(** Helper function that adds an order ID to the accumulator list if the order matches the specified status and origin
    @param order The order to check
    @param status The status to match against
    @param origin The origin to match against
    @param acc The accumulator list
    @return Updated list with order ID appended if matching criteria
*)
let return_order_id_if_match_status_and_origin order status origin acc =
  match order with
  | {status = s; origin = o; _ } when s = status && o = origin -> order.id :: acc
  | _ -> acc

(** Filters a list of orders by status and origin, returning a list of matching order IDs
    @param orders List of orders to filter
    @param status The status to filter by
    @param origin The origin to filter by
    @return List of order IDs that match the criteria
*)
let filter_orders_by_status_and_origin orders status origin =
  List.fold_left (fun acc order -> return_order_id_if_match_status_and_origin order status origin acc) [] orders

(** Checks if an order item belongs to the specified order ID
    @param id_searched The order ID to check for
    @param od_item The order item to examine
    @return True if the order item belongs to the specified order ID, false otherwise
*)
let check_order_item_id id_searched od_item =
  match od_item with
  | {order_id = od_id; _} when od_id = id_searched -> true
  | _ -> false

(** Aggregates order items for a specific order ID into summary information
    @param od_items List of all order items
    @param od_id The order ID to aggregate information for
    @return An aggregated order info record with total amounts and taxes
*)
let agg_order_info_of_id od_items od_id =
  let order_items_from_id = List.filter (fun item -> check_order_item_id od_id item) od_items in
  let amounts = List.map (fun od_item -> (float_of_int od_item.quantity) *. od_item.price) order_items_from_id in
  let taxes = List.map (fun od_item -> (float_of_int od_item.quantity) *. od_item.price *. od_item.tax) order_items_from_id in 
  {order_id_ = od_id; total_amount = List.fold_left (+.) 0. amounts; total_taxes = List.fold_left (+.) 0. taxes}

(** Transforms a list of order IDs into aggregated order information
    @param ids List of order IDs to process
    @param od_items List of all order items
    @return List of aggregated order information records
*)
let transform_orders_to_agg_info ids od_items = 
  List.map (fun id -> agg_order_info_of_id od_items id) ids

(** Extracts month and year from datetime
    @param dt Datetime tuple
    @return Month-year record
*)
let extract_month_year dt =
  match dt with
  | (Year y, Month m, _, _, _, _) -> { year = y; month = m }

(** Compares two month-year records
    @param my1 First month-year
    @param my2 Second month-year
    @return Negative if my1 < my2, 0 if equal, positive if my1 > my2
*)
let compare_month_year my1 my2 =
  let year_diff = my1.year - my2.year in
  if year_diff != 0 then year_diff else my1.month - my2.month

(** Checks if a month-year is between two others (inclusive)
    @param my Month-year to check
    @param start Start month-year
    @param end_my End month-year
    @return True if my is between start and end_my (inclusive)
*)
(* let is_month_year_between my start end_my =
  compare_month_year my start >= 0 && compare_month_year my end_my <= 0 *)

(** Increments a month-year by one month
    @param my Month-year to increment
    @return Next month-year
*)
let increment_month_year my =
  if my.month = 12 then
    { year = my.year + 1; month = 1 }
  else
    { year = my.year; month = my.month + 1 }

(** Generates a list of all month-years from start to end (inclusive)
    @param start Start month-year
    @param end_my End month-year
    @return List of all month-years in the range
*)
let rec generate_month_year_list start end_my =
  if compare_month_year start end_my > 0 then []
  else start :: generate_month_year_list (increment_month_year start) end_my

(** Finds the minimum and maximum month-year in a list of orders
    @param orders List of orders
    @return Tuple of (min_month_year, max_month_year)
*)
let find_month_year_range orders =
  let extract_my_from_order order = extract_month_year order.order_date in
  
  let update_min_max current_min current_max order =
    let my = extract_my_from_order order in
    let new_min = 
      match current_min with
      | None -> Some my
      | Some min_my -> if compare_month_year my min_my < 0 then Some my else Some min_my
    in
    let new_max = 
      match current_max with
      | None -> Some my
      | Some max_my -> if compare_month_year my max_my > 0 then Some my else Some max_my
    in
    (new_min, new_max)
  in
  
  let min_max_opt = List.fold_left 
    (fun (min_acc, max_acc) order -> update_min_max min_acc max_acc order)
    (None, None)
    orders
  in
  
  match min_max_opt with
  | (Some min_my, Some max_my) -> (min_my, max_my)
  | _ -> ({ year = 0; month = 0 }, { year = 0; month = 0 }) (* Default if no orders *)

(** Checks if an order belongs to a specific month-year
    @param order Order to check
    @param my Month-year to match against
    @return True if order belongs to the month-year
*)
let is_order_in_month_year order my =
  let order_my = extract_month_year order.order_date in
  order_my.year = my.year && order_my.month = my.month

(** Filters orders that match a specific month-year
    @param orders List of orders
    @param my Month-year to filter by
    @return List of orders in the specified month-year
*)
let filter_orders_by_month_year orders my =
  List.filter (fun order -> is_order_in_month_year order my) orders

(** Aggregates order information for a specific month-year
    @param orders List of all orders
    @param order_items List of all order items
    @param my Month-year to aggregate for
    @return Aggregated information for the month-year with average values
*)
let agg_month_year_info orders order_items my =
  let month_year_orders = filter_orders_by_month_year orders my in
  let order_count = List.length month_year_orders in
  
  if order_count = 0 then
    {
      month_year = my;
      avg_amount = 0.0;
      avg_taxes = 0.0;
      order_count = 0;
    }
  else
    let order_ids = List.map (fun order -> order.id) month_year_orders in
    let agg_orders : agg_order_info list = transform_orders_to_agg_info order_ids order_items in
    
    (* Calcular totais *)
    let total_amount = List.fold_left (fun acc (order_info : agg_order_info) -> 
      acc +. order_info.total_amount) 0.0 agg_orders in
    
    let total_taxes = List.fold_left (fun acc (order_info : agg_order_info) -> 
      acc +. order_info.total_taxes) 0.0 agg_orders in
    
    (* Calcular médias *)
    let avg_amount = total_amount /. (float_of_int order_count) in
    let avg_taxes = total_taxes /. (float_of_int order_count) in
    
    {
      month_year = my;
      avg_amount;
      avg_taxes;
      order_count;
    }

(** Transforms orders into aggregated month-year information
    @param orders List of all orders
    @param order_items List of all order items
    @return List of aggregated information for each month-year
*)
let transform_orders_to_month_year_agg orders order_items =
  let (min_my, max_my) = find_month_year_range orders in
  let month_years = generate_month_year_list min_my max_my in
  List.map (fun my -> agg_month_year_info orders order_items my) month_years

