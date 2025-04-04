open Etl_funcs.CustomTypes

let status_to_analise = Complete
let origin_to_analise = Online

let raw_orders = Etl_funcs.ReadData.load_orders ()
let raw_order_items = Etl_funcs.ReadData.load_order_items ()

let order_records = Etl_funcs.ParseData.parse_order raw_orders
let order_items_records = Etl_funcs.ParseData.parse_order_item raw_order_items

let filtered_orders = Etl_funcs.TransformData.filter_orders_by_status_and_origin order_records status_to_analise origin_to_analise 

let agg_information = Etl_funcs.TransformData.transform_orders_to_agg_info filtered_orders order_items_records

let csv_agg_info = Etl_funcs.ParseData.parse_agg_order_to_csv agg_information

let () = Csv.save "data/processed/agg_order.csv" csv_agg_info