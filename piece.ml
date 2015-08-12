open Common_types

(*
let piece_members p =
    let members = p.p_members in
    Geometry.trans_members p.trans members p.p_pivot
*)

let eq p1 p2 = p1.p_pivot = p2.p_pivot && p1.trans = p2.trans

let valid board c = 
    c.x >= 0 && c.y >= 0 && c.x < Array.length board && c.y < Array.length board.(0)

let empty board c = 
    let cs = board.(c.x).(c.y) in
    cs = EMPTY

let fits board members =
    let l = ref members in
    let fit = ref true in
    while !fit && !l <> [] do
        let c = List.hd !l in
        l := List.tl !l;
        if not (valid board c && empty board c)
        then fit := false
    done;
    !fit

let place board members = List.iter (fun c -> board.(c.x).(c.y) <- CURRENT) 
    members
let unplace board members = List.iter (fun c -> board.(c.x).(c.y) <- EMPTY)
    members

let unit_color = [|
    (255,0,0); (0,255,0); (0,0,255);
    (255,255,0); (0,255,255); (255,0,255);
    (128,128,0); (0,128,128); (128,0,128);
    (255,128,0); (0,255,128); (255,0,128);
    (128,255,0); (0,128,255); (128,0,255)
    |]

let nunit_color = Array.length unit_color

let lock board piece = 
    let id = piece.unt.id in
    let col = Gui.get_color 
        unit_color.(id mod nunit_color) in
    List.iter (fun c -> board.(c.x).(c.y) <- LOCKED col)
        piece.p_members
    
let spawn u width =
    let bb = Geometry.bbox u.members in
    let length = bb.right - bb.left + 1 in
    let real_left = (width - length) / 2 in
    let dec = fun c -> {x=c.x-bb.left+real_left; y=c.y-bb.top} in
    let p_members = List.map dec u.members in
    { unt=u; trans=0; p_members=p_members; p_pivot=dec u.pivot  }

let move p m =
    match m with
    | CW -> 
        let r = (p.trans + 1) mod p.unt.symmetry in
        { unt=p.unt; trans=r; p_pivot=p.p_pivot; 
            p_members=List.map (Geometry.trans_cell 1 p.p_pivot) p.p_members }
    | CCW -> 
        let r = (p.trans - 1) mod p.unt.symmetry in
        { unt=p.unt; trans=if r >= 0 then r else r+p.unt.symmetry; p_pivot=p.p_pivot; 
            p_members=List.map (Geometry.trans_cell 5 p.p_pivot) p.p_members }
    | _ -> let move_cell c = 
        match m, c.y mod 2 with
        | E, _ -> {x=c.x+1;y=c.y}
        | W, _ -> {x=c.x-1;y=c.y}
        | SW, 0 -> {x=c.x-1;y=c.y+1}
        | SW, 1 -> {x=c.x;y=c.y+1}
        | SE, 1 -> {x=c.x+1;y=c.y+1}
        | _ -> {x=c.x;y=c.y+1}
        in 
        { unt=p.unt;
          trans=p.trans;
          p_pivot=move_cell p.p_pivot;
          p_members=List.map move_cell p.p_members }


let hash p = (p.p_pivot,p.trans)

exception InvalidPow
let rec move_pow board hashes pos pow acc =
    match pow with
    | [] -> pos, List.map hash acc
    | m::q -> let p2 = move pos m in
        if not (List.mem (hash p2) hashes) && fits board p2.p_members
        then move_pow board (hash p2 :: hashes) p2 q (p2::acc)
        else raise InvalidPow
