(** This module handles loading data from external sources *)

(** Loads order data from a CSV file
    @return Raw CSV data containing orders
*)
let load_orders () = Csv.load "data/raw/order.csv"

(** Loads order item data from a CSV file
    @return Raw CSV data containing order items
*)
let load_order_items () = Csv.load "data/raw/order_item.csv"