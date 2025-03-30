open CustomTypes

let return_order_id_if_match_status_and_origin order status origin acc =
  match order with
  | {status = s; origin = o; _ } when s = status && o = origin -> order.id :: acc
  | _ -> acc

let filter_orders_by_status_and_origin orders status origin =
  List.fold_left (fun acc order -> return_order_id_if_match_status_and_origin order status origin acc) [] orders

let check_order_item_id id_searched od_item =
  match od_item with
  | {order_id = od_id; _} when od_id = id_searched -> true
  | _ -> false

let agg_order_info_of_id od_items : order_item_list -> od_id : int -> agg_order_info =

    let order_items_from_id = List.filter (check_order_item_id od_id) od_items 
  in
    let amounts = List.map (fun od_item : order_item -> (of_int od_item.quantity) *. od_item.price) order_items_from_id
  in
    let taxes = List.map (fun od_item : order_item -> (of_int od_item.quantity) *. od_item.price *. od_item.tax) order_items_from_id
  in 
    {order_id = od_id ; total_amount = List.fold_left (+) 0 amounts ; total_taxes = List.fold_left (+) 0 taxes}

let transform_orders_to_agg_info ids : int list -> od_item_ls = 
  List.map (agg_order_info_of_id od_item_ls) ids
