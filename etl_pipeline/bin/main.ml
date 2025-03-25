open Etl_funcs.Custom_types

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
  
let () =
  Printf.printf "Loading and parsing orders...\n";
  let csv_orders = Etl_funcs.Impure.load_orders () in
  
  try
    let parsed_orders = Etl_funcs.Impure.parse_order csv_orders in
    
    Printf.printf "Successfully parsed %d orders.\n\n" (List.length parsed_orders);
    
    (* Print first 5 orders as example *)
    let orders_to_print = min 5 (List.length parsed_orders) in
    Printf.printf "Showing first %d orders:\n\n" orders_to_print;
    
    List.iteri (fun i order ->
      if i < orders_to_print then (
        Printf.printf "Order #%d:\n" (i + 1);
        print_order_record order
      )
    ) parsed_orders
    
  with e ->
    Printf.printf "Error during parsing: %s\n" (Printexc.to_string e);
    Printexc.print_backtrace stdout