open Common_types 

let neighbours board c =
    let dec = if c.y mod 2 = 0
        then [ (-1,-1); (-1,0); (-1,1); (0,-1); (0,1); (1,0) ]
        else [ (1,-1); (1,0); (1,1); (0,-1); (0,1); (-1,0) ]
    in
    let neigh = ref [] in
    List.iter
        (fun (dx,dy) ->
            let dc = {x=c.x+dx;y=c.y+dy} in
            if Piece.valid board dc && Piece.empty board dc
            then neigh := dc :: !neigh)
        dec;
    !neigh

let rec concat_unique l1 l2 =
    match l1 with
    | [] -> l2
    | t::q when List.mem t l2 -> concat_unique q l2
    | t::q -> t :: concat_unique q l2

let rec min_list l = 
    match l with
    | [] -> raise Not_found
    | [t] -> t
    | t::q -> let mq = min_list q in if t < mq then t else mq

let piece_neighbours board p =
    (*
    List.iter (fun c ->
        Printf.eprintf "%s -- %s\n"
            (Data.string_of_cell c)
            (Data.string_of_cells (neighbours board c)))
        p.p_members;
    Printf.eprintf "\n";
    flush stderr;
    *)
    List.fold_left concat_unique []
        (List.map (neighbours board) p.p_members)

type visit = UNK | SEEN | VIS
let connected_components board max_depth piece =
    let w, h = Board.dim board in
    (*
    let debug_board = Array.make_matrix w h EMPTY in
    for x = 0 to w-1 do for y = 0 to h-1 do debug_board.(x).(y) <- board.(x).(y) done done;
    *)
    let visited = Array.make_matrix w h UNK in
    let components = Array.make_matrix w h 0 in
    let tovisit = Queue.create () in
    let free_component_number = ref 0 in

    let seen = ref [] in

    List.iter (fun c -> 
        if visited.(c.x).(c.y) = UNK
        then begin
            let component = ref [ ] in
            let tofuse = ref [] in
            Queue.add (c,0) tovisit;
            while not (Queue.is_empty tovisit) do
                let v,depth = Queue.take tovisit in

                let curcomp = components.(v.x).(v.y) in

                if curcomp <> 0 && not (List.mem curcomp !tofuse)
                then begin
                    tofuse := curcomp :: !tofuse
                end;
                     
                if visited.(v.x).(v.y) <> VIS
                then begin
                    seen := v :: !seen;
                                   
                    if curcomp = 0 then component := v :: !component;

                    visited.(v.x).(v.y) <- VIS;
                    if depth < max_depth
                    then List.iter 
                            (fun nv ->
                                if true || visited.(nv.x).(nv.y) = UNK
                                then begin
                                    Queue.add (nv,depth+1) tovisit;
                                end)
                            (neighbours board v)
                end
            done;

            if !tofuse = []
            then begin
                incr free_component_number;
                let my_comp = !free_component_number in
                List.iter (fun v ->
                    components.(v.x).(v.y) <- my_comp;
                    
                    (*
                        let gray = 32 * my_comp in
                        debug_board.(v.x).(v.y) <- LOCKED (Gui.get_color
                                (gray,gray,gray));
                    *) 
                    
                    )
                    (List.rev !component)
            end else begin
                let my_comp = min_list !tofuse in
                List.iter (fun v ->
                    let cv = components.(v.x).(v.y) in
                    if List.mem cv !tofuse || cv = 0
                    then begin
                        components.(v.x).(v.y) <- my_comp;

                        (*
                        let gray = 32 * my_comp in
                        debug_board.(v.x).(v.y) <- LOCKED (Gui.get_color
                                (gray,gray,gray));
                                *)

                    end)
                    (List.rev !seen)
            end;


        end)
        (piece_neighbours board piece);
    (*
    if List.length piece.p_members > 1
    then begin
        Board.print debug_board;
        Gui.pause();
    end;
    *)


    let current_components = ref [] in
    List.iter (fun v ->
        let curcomp = components.(v.x).(v.y) in
        if not (List.mem curcomp !current_components)
        then current_components := curcomp :: !current_components)
        !seen;

        (*
    if List.length piece.p_members > 1
    then begin
        Gui.util_text (Printf.sprintf "%d" (List.length !current_components));
        Board.print debug_board;
        Gui.pause();
    end;
    *)
    List.length !current_components

