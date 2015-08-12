open Common_types

let ( +$ ) p1 p2 = {x=p1.x+p2.x; y=p1.y+p2.y }
let ( -$ ) p1 p2 = {x=p1.x-p2.x; y=p1.y-p2.y }

let tohex p = { x=p.x-p.y/2; y=p.y }
let fromhex p = {x=p.x+p.y/2; y=p.y }

let rotate60_hex p c =
    let v = c -$ p in
    p +$ {x= - v.y; y=v.x+v.y}

let trans_cell t p c =
    let htp = tohex p in
    let htc = ref (tohex c) in
    for i = 1 to t do
        htc := rotate60_hex htp !htc
    done;
    fromhex !htc

let bbox ca =
    let min_x = ref max_int in
    let max_x = ref min_int in
    let min_y = ref max_int in
    let max_y = ref min_int in
    List.iter (fun c ->
            if c.x > !max_x
            then max_x := c.x;
            if c.y > !max_y
            then max_y := c.y;
            if c.x < !min_x
            then min_x := c.x;
            if c.y < !min_y
            then min_y := c.y) ca;
    { left= !min_x; right= !max_x; top= !min_y; bottom= !max_y }

let trans_bbox b v =
    { left=b.left+v.x; right=b.right+v.x;
      top=b.top+v.y;bottom=b.bottom+v.y }

let trans_members t memb p = List.map (trans_cell t p) memb

