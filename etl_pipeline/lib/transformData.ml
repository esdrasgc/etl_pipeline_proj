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
