(** This module defines custom types used throughout the ETL pipeline *)

(** Represents the current status of an order *)
type order_status = Pending | Complete | Cancelled | Unknown_status

(** Represents the origin channel of an order *)
type order_origin = Online | InPerson | Unknown_origin

(** Components of date and time *)
type year = Year of int 

type month = Month of int

type day = Day of int

type hour = Hour of int

type minutes = Minutes of int

type seconds = Seconds of int

(** Represents a full datetime as a tuple of components *)
type datetime = year * month * day * hour * minutes * seconds 

(** Represents an order record with its attributes *)
type order = {
    id : int;
    client_id : int;
    order_date : datetime;
    status: order_status;
    origin: order_origin;
}

(** Represents an item within an order *)
type order_item = {
    order_id : int;
    product_id : int;
    quantity : int;
    price : float;
    tax : float;
}

(** Represents aggregated information for an order *)
type agg_order_info = {
    total_amount : float;
    total_taxes : float;
    order_id_ : int;
}

(** Represents a month-year pair for aggregation *)
type month_year = {
  year: int;
  month: int;
}

(** Represents aggregated information for a month-year period *)
type agg_month_year_info = {
  month_year: month_year;
  avg_amount: float;
  avg_taxes: float;
  order_count: int;  (* mantido para cálculos internos *)
}

(** List of integer IDs *)
type ids_list = int list 

(** List of order items *)
type order_item_list = order_item list

(** List of orders *)
type order_list = order list

(** List of month-year pairs *)
type month_year_list = month_year list

(** List of aggregated month-year information *)
type agg_month_year_info_list = agg_month_year_info list