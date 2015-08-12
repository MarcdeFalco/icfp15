open Common_types

(* PRETTY-PRINTING *)
let string_of_cell {x=x;y=y} = "(" ^ string_of_int x ^ "," ^ string_of_int y ^ ")"
let string_of_cells c = "[" ^ String.concat "," (List.map string_of_cell c) ^ "]"

let string_of_bbox {left=left;right=right;top=top;bottom=bottom} =
    Printf.sprintf "(%d,%d->%d,%d)" left top right bottom

let string_of_unit u =
    "{[" ^ String.concat "," (List.map string_of_cell u.members)
        ^ "]," ^ string_of_cell u.pivot
        ^ "," ^ string_of_int u.symmetry
        ^ ",[" ^ String.concat ","
            (List.map string_of_bbox (Array.to_list u.bboxes))
        ^ "]}"

let string_of_problem p =
    "(" ^ string_of_int p.id
    ^ "," ^ string_of_int p.sourceLength
    ^ ",[" ^ String.concat "," (List.map string_of_int 
        (Array.to_list p.sourceSeeds))
    ^ "],[" ^ String.concat "," (List.map string_of_unit 
        (Array.to_list p.units))
    ^ "],[" ^ String.concat "," (List.map string_of_cell p.filled)
    ^ "])"

(* JSON PARSING *)
let count_id = ref 0
let parse_unit json =
  let open Yojson.Basic.Util in
  let members_json = json |> member "members" |> to_list in
  let members = List.map 
    (fun json -> {x=json |> member "x" |> to_int;
               y=json |> member "y" |> to_int}) 
    members_json
  in
  let pivot = 
      {x=json |> member "pivot" |> member "x" |> to_int;
       y=json |> member "pivot" |> member "y" |> to_int} in

  let symmetry = 
      let p1 = Geometry.trans_members 1 members pivot in
      let p2 = Geometry.trans_members 2 members pivot in
      let p3 = Geometry.trans_members 3 members pivot in
      if Utils.contains p1 members
      then 1
      else if Utils.contains p2 members
        then 2
        else if Utils.contains p3 members
        then 3
        else 6
    in

  let bboxes = Array.init symmetry
    (fun r -> 
        let t = r in
      Geometry.bbox (Geometry.trans_members t members pivot))
  in

  let id = !count_id in
  incr count_id;
  { id=id; members=members; pivot=pivot;
    symmetry=symmetry; bboxes=bboxes }

let parse_problem json =
  let open Yojson.Basic.Util in
  let id = json |> member "id" |> to_int in
  let width = json |> member "width" |> to_int in
  let height = json |> member "height" |> to_int in

  let units_json = json |> member "units" |> to_list in
  let units = Array.of_list (List.map parse_unit units_json) in

  let filled_json = json |> member "filled" |> to_list in
  let filled = List.map 
    (fun json -> {x=json |> member "x" |> to_int;
               y=json |> member "y" |> to_int}) 
    filled_json in

  let sourceLength = json |> member "sourceLength" |> to_int in
  let sourceSeeds = Array.of_list
    (List.map to_int (json |> member "sourceSeeds" |> to_list)) in

  { width=width; height=height; filled=filled;
    units=units; id=id; sourceLength=sourceLength; sourceSeeds=sourceSeeds }

let problem_from_file fn =
  let json = Yojson.Basic.from_file fn in
  parse_problem json

