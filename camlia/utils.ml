let rec contains l1 l2 =
    match l1 with
    | [] -> true
    | t::q -> if List.mem t l2 then contains q l2 else false
