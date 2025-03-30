type order_status = Pending | Complete | Cancelled | Unknown_status

type order_origin = Online | InPerson | Unknown_origin

type year = Year of int 
type month = Month of int
type day = Day of int
type hour = Hour of int
type minutes = Minutes of int
type seconds = Seconds of int

type datetime = year * month * day * hour * minutes * seconds 

(* type identifier = int *)

type order = {
    id : int;
    client_id : int;
    order_date : datetime;
    status: order_status;
    origin: order_origin;
}

type order_item = {
    order_id : int;
    product_id : int;
    quantity : int;
    price : float;
    tax : float;
}

type agg_order_info = {
    total_amount : float;
    total_taxes : float;
    order_id_ : int;
}

type ids_list = int list 
type order_item_list = order_item list
type order_list = order list