open Common_types

let cw = 15

let sw = ref 0
let sh = ref 0
let init w h =
    sw := (cw * (2+w));
    sh := (15*4 + cw * (h));
    Graphics.open_graph (Printf.sprintf " %dx%d" !sw !sh)

let close () = Graphics.close_graph ()

let convert_point h c =
    let shift = c.y mod 2 in
    { x=cw*(1+c.x)+shift*cw/2; y=(h-c.y-1) * cw + 15*4 }

let plot_point h c =
    let v = convert_point h c in
    Graphics.fill_circle v.x v.y (cw / 4)

let fond = Graphics.rgb 240 240 240
let current = Graphics.rgb 255 155 155
let filled = Graphics.rgb 50 50 50
let set_color cs = 
    let col = match cs with
        | EMPTY -> fond
        | LOCKED c -> c
        | CURRENT -> current
        | FILLED -> filled
        in 
    Graphics.set_color col

let pi = acos (-1.0)
let foi = float_of_int
let iof = int_of_float
let a,b,c = 5,4,3
let a,b,c = 9, 7, 6
(*
let a,b,c = cw/2, iof (foi cw *. cos (pi /. 12.0) /. 2.), iof (foi cw *. sin (pi /. 12.0) /. 2.)
*)
let hexagon = [| (0,a); (-b,c); (-b,-c); (0,-a); (b+1,-c); (b+1,c) |]
    (*
    Array.init 6
    (fun i ->
        let cwf = float_of_int cw /. 1.55 in
        let i_f = float_of_int i in
        let d = pi/. 2. in
        let x = cwf *. cos(2.*.i_f*.pi/.6.+.d) in
        let y = if i = 0 then cwf
            else if i = 3 then -cwf
            else cwf *. sin(2.*.i_f*.pi/.6.+.d) in
        (int_of_float x, int_of_float y))
        *)


let plot_cell h c cs =
    let v = convert_point h c in
    let hext = Array.map (fun (x,y) -> (x+v.x,y+v.y)) hexagon in
    set_color cs;
    Graphics.fill_poly hext;
    Graphics.set_color (Graphics.rgb 200 200 200);
    Graphics.draw_poly hext
    (*
    Graphics.set_color Graphics.black;
    Graphics.draw_poly_line hext
    *)
    (* Graphics.fill_circle v.x v.y (cw / 2); *)
    (*
    Graphics.set_color Graphics.black;
    Graphics.draw_circle v.x v.y (cw / 2)
    *)

let util_text s =
    Graphics.set_text_size 15;
    Graphics.moveto 15 15;
    Graphics.set_color Graphics.white;
    Graphics.fill_rect 15 15 300 15;
    Graphics.set_color Graphics.black;
    Graphics.draw_string s

let score scr inc pscr =
    Graphics.set_text_size 15;
    Graphics.set_color Graphics.white;
    Graphics.fill_rect 15 0 300 30;
    Graphics.set_color Graphics.black;
    Graphics.moveto 15 15;
    Graphics.draw_string
        (Printf.sprintf "Move %d (+%d)"  scr inc);
    Graphics.moveto 15 0;
    Graphics.draw_string
        (Printf.sprintf "+ Power %d = %d"
            pscr (scr +pscr))

let bonus_text s =
    Graphics.set_text_size 30;
    let tw, th = Graphics.text_size s in
    Graphics.moveto ((!sw-tw)/2) ((!sh-th)/2);
    Graphics.set_color Graphics.white;
    Graphics.fill_rect 0 ((!sh-th)/2) !sw th;
    Graphics.set_color Graphics.red;
    Graphics.draw_string s

let pause () = let _ = Graphics.read_key () in ()

let get_color (r,g,b) = Graphics.rgb r g b

let image_id = ref 0 
let flush pid seed = 
    let im = Graphics.get_image 0 0 !sw !sh in
    let cim = Images.Rgb24 (Graphic_image.image_of im) in
    Png.save (Printf.sprintf "imgs/problem_%02d_%06d_%05d.png" pid seed !image_id) [] cim;
    incr image_id

(*
let init w h = ()
let close () = ()
let convert_point h c = ()
let plot_point h c = ()
let set_color cs = ()
let plot_cell h c cs = ()
let score scr inc = ()
*)

