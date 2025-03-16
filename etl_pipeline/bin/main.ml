
(* let orders = Etl_funcs.Impure.load_orders () in
Csv.print_readable orders *)

let csv_orders = Etl_funcs.Impure.load_orders () in
  Etl_funcs.Impure.parse_order csv_orders
  |> List.iter (function
    | Ok order ->
        Printf.printf "%d %d\n"
          order.id
          order.client_id
          (* (Etl_funcs.Pure.show_order_status order.status) *)
    | Error `Invalid_id ->
        print_endline "Invalid_id"
    | Error `Unknown_origin ->
        print_endline "Unknown_origin"
    | Error `Unknown_status ->
        print_endline "Missing_status")