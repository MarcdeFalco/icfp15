open Common_types

let interactive = false

let init w h = ()
let start_board w h =
    Printf.eprintf "\\hexgrid{%d}{%d}" w h
let end_board () = ()
let close () = ()
let pause () = ()
let convert_point h c = ()
let set_color cs = ()
let plot_cell h c cs =
    match cs with
    | LOCKED cs ->
        Printf.eprintf "\\node[hexcell,piece%c] at (h%d;%d.south) {};"
            (Char.chr (Char.code 'a'+cs)) c.x c.y 
    | CURRENT cs ->
        Printf.eprintf "\\node[hexcell,piece%c] at (h%d;%d.south) {};"
            (Char.chr (Char.code 'a'+cs)) c.x c.y 
    | FILLED ->
        Printf.eprintf "\\node[hexcell,filled] at (h%d;%d.south) {};"
            c.x c.y 
    | _ -> ()
        
let score scr inc _ = ()
let util_text t  = ()
let get_color id = id
let bonus_text s = ()
let wait _ = ()

let plot_point h c = 
    Printf.eprintf "\\pivot{%d}{%d}" c.x c.y
