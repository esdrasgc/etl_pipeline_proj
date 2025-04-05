open CustomTypes
val parse_order : Csv.t -> order list
val parse_order_item : Csv.t -> order_item list

val parse_agg_order_to_csv : agg_order_info list -> Csv.t

(** Converts a list of aggregated month-year info records to CSV format *)
val parse_agg_month_year_to_csv : agg_month_year_info list -> Csv.t