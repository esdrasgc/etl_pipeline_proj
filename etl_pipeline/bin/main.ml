(* open Etl_funcs.Custom_types
let () =
  let csv_orders = Etl_funcs.Impure.load_orders () in
    
    let header, data = match csv_orders with h :: d -> h, d | [] -> [], [] in
      let teste = Csv.associate header data in
      let flattened = List.concat teste in
      List.iter (fun (key, value) ->
        Printf.printf "Chave: %s, Valor: %s\n" key value
      ) flattened *)

open Etl_funcs.Custom_types

let print_order_record order =
  Printf.printf "Order ID: %d\n" order.id;
  Printf.printf "Client ID: %d\n" order.client_id;
  
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