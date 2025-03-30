open Etl_funcs.CustomTypes

let print_datetime (Year year, Month month, Day day, Hour hour, Minutes min, Seconds sec) =
  Printf.printf "Date: %04d-%02d-%02d %02d:%02d:%02d\n" year month day hour min sec

let print_status = function
  | Pending -> "Pending"
  | Complete -> "Complete"
  | Cancelled -> "Cancelled"
  | Unknown_status -> "Unknown"

let print_origin = function
  | Online -> "Online"
  | InPerson -> "In Person"
  | Unknown_origin -> "Unknown"

let print_order_record order =
  Printf.printf "Order ID: %d\n" order.id;
  Printf.printf "Client ID: %d\n" order.client_id;
  print_datetime order.order_date;
  Printf.printf "Status: %s\n" (print_status order.status);
  Printf.printf "Origin: %s\n" (print_origin order.origin);
  Printf.printf "\n"

let print_order_item_record item =
  Printf.printf "Order ID: %d\n" item.order_id;
  Printf.printf "Product ID: %d\n" item.product_id;
  Printf.printf "Quantity: %d\n" item.quantity;
  Printf.printf "Price: %.2f\n" item.price;
  Printf.printf "Tax: %.2f\n" item.tax;
  Printf.printf "\n"

let print_agg_order_info info =
  Printf.printf "Order ID: %d\n" info.order_id_;
  Printf.printf "Total Amount: %.2f\n" info.total_amount;
  Printf.printf "Total Taxes: %.2f\n" info.total_taxes;
  Printf.printf "\n"

let () =
  Printf.printf "Loading and parsing orders...\n";
  let csv_orders = Etl_funcs.ReadData.load_orders () in
  
  try
    let parsed_orders = Etl_funcs.ParseData.parse_order csv_orders in
    
    Printf.printf "Successfully parsed %d orders.\n\n" (List.length parsed_orders);
    
    (* Print first 3 orders as example *)
    let orders_to_print = min 3 (List.length parsed_orders) in
    Printf.printf "Showing first %d orders:\n\n" orders_to_print;
    
    List.iteri (fun i order ->
      if i < orders_to_print then (
        Printf.printf "Order #%d:\n" (i + 1);
        print_order_record order
      )
    ) parsed_orders;
    
    (* Load and parse order items *)
    Printf.printf "Loading and parsing order items...\n";
    let csv_order_items = Etl_funcs.ReadData.load_order_items () in
    
    let parsed_order_items = Etl_funcs.ParseData.parse_order_item csv_order_items in
    
    Printf.printf "Successfully parsed %d order items.\n\n" (List.length parsed_order_items);
    
    (* Print first 3 order items as example *)
    let items_to_print = min 3 (List.length parsed_order_items) in
    Printf.printf "Showing first %d order items:\n\n" items_to_print;
    
    List.iteri (fun i item ->
      if i < items_to_print then (
        Printf.printf "Order Item #%d:\n" (i + 1);
        print_order_item_record item
      )
    ) parsed_order_items;
    
    let list_of_ids = Etl_funcs.TransformData.filter_orders_by_status_and_origin parsed_orders Complete Online in
    Printf.printf "\nFiltered order IDs:\n";
    List.iter (fun id -> Printf.printf "Id: %d\n" id) list_of_ids;
    
    let agg_info = Etl_funcs.TransformData.transform_orders_to_agg_info list_of_ids parsed_order_items in
    Printf.printf "\nAggregated order information:\n";
    List.iter print_agg_order_info agg_info
    
  with e ->
    Printf.printf "Error during parsing: %s\n" (Printexc.to_string e);
    Printexc.print_backtrace stdout