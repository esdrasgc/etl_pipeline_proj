open Custom_types

(* let show_order_status = function
    | Pending -> "Pending"
    | Complete -> "Complete"
    | Cancelled -> "Cancelled" *)


let parse_status = function
  | "Pending" -> Pending
  | "Complete" -> Complete
  | "Cancelled" -> Cancelled
  | _ -> Unknown_status

let parse_origin = function
  | "O" -> Online
  | "P" -> InPerson
  | _ -> Unknown_origin
