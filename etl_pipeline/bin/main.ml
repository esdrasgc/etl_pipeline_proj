(** Main entry point for the ETL pipeline
    This module orchestrates the entire ETL process:
    1. Extract: Load raw order and order item data
    2. Transform: Filter and aggregate data
    3. Load: Save the processed data to CSV
*)
open Etl_funcs.CustomTypes

(** Order status we want to analyze *)
let status_to_analise = Complete

(** Order origin we want to analyze *)
let origin_to_analise = Online

(** Extract: Load raw data from CSV files *)
let raw_orders = Etl_funcs.ReadData.load_orders ()
let raw_order_items = Etl_funcs.ReadData.load_order_items ()

(** Parse: Convert raw CSV data to structured records *)
let order_records = Etl_funcs.ParseData.parse_order raw_orders
let order_items_records = Etl_funcs.ParseData.parse_order_item raw_order_items

(** Transform: Filter orders based on status and origin *)
let filtered_orders = Etl_funcs.TransformData.filter_orders_by_status_and_origin order_records status_to_analise origin_to_analise 

(** Transform: Aggregate order information *)
let agg_information = Etl_funcs.TransformData.transform_orders_to_agg_info filtered_orders order_items_records

(** Transform: Aggregate order information by month and year *)
let month_year_agg_information = Etl_funcs.TransformData.transform_orders_to_month_year_agg order_records order_items_records

(** Load: Convert aggregated data to CSV format *)
let csv_agg_info = Etl_funcs.ParseData.parse_agg_order_to_csv agg_information

(** Load: Convert month-year aggregated data to CSV format *)
let csv_month_year_agg_info = Etl_funcs.ParseData.parse_agg_month_year_to_csv month_year_agg_information

(** Load: Save both processed data files *)
let () = 
  Csv.save "data/processed/agg_order.csv" csv_agg_info;
  Csv.save "data/processed/agg_month_year.csv" csv_month_year_agg_info