open CustomTypes

val filter_orders_by_status_and_origin : order_list -> order_status -> order_origin -> ids_list
val transform_orders_to_agg_info : ids_list -> order_item_list -> agg_order_info list

(** Extracts month and year from datetime *)
val extract_month_year : datetime -> month_year

(** Finds the minimum and maximum month-year in a list of orders *)
val find_month_year_range : order_list -> month_year * month_year

(** Transforms orders into aggregated month-year information *)
val transform_orders_to_month_year_agg : order_list -> order_item_list -> agg_month_year_info list
