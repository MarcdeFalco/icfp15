open Common_types

let cw = 20

(*
let init w h =
    Graphics.open_graph (Printf.sprintf " %dx%d"
        (cw * (2+w)) (cw * (2+h)))

let close () = Graphics.close_graph ()

let convert_point h c =
    let shift = c.y mod 2 in
    { x=cw*(1+c.x)+shift*10; y=(h-c.y) * cw }

let plot_point h c =
    let v = convert_point h c in
    Graphics.fill_circle v.x v.y (cw / 4)

let set_color cs = 
    let col = match cs with
        | EMPTY -> Graphics.white
        | LOCKED -> Graphics.blue
        | CURRENT -> Graphics.green
        | FILLED -> Graphics.red
        in 
    Graphics.set_color col

let plot_cell h c cs =
    let v = convert_point h c in
    set_color cs;
    Graphics.fill_circle v.x v.y (cw / 2);
    Graphics.set_color Graphics.black;
    Graphics.draw_circle v.x v.y (cw / 2)

let score scr inc =
    Graphics.moveto 0 0;
    Graphics.set_color Graphics.white;
    Graphics.fill_rect 0 0 300 10;
    Graphics.set_color Graphics.black;
    Graphics.draw_string
        (Printf.sprintf "Score %d (+%d)" scr inc)
        *)

let init w h = ()
let close () = ()
let pause () = ()
let convert_point h c = ()
let plot_point h c = ()
let set_color cs = ()
let plot_cell h c cs = ()
let score scr inc _ = ()
let util_text t  = ()
let get_color c = 0
let bonus_text s = ()
let wait _ = ()
let start_board _ _ = ()
let end_board () = ()
let interactive = false
