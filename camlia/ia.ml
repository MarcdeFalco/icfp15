open Sys
open Common_types

type move = Single of movement | Power of int
let phrases_string  =
    let phrase_file = open_in Sys.argv.(2) in
    let phrases_acc = ref [] in
    (try
        while true do
            let phrase = input_line phrase_file in
            phrases_acc := phrase :: !phrases_acc
        done
    with End_of_file -> ());
    Array.of_list (List.rev !phrases_acc)


(*
= [| "ph'nglui mglw'nafh cthulhu r'lyeh wgah'nagl fhtagn."; "case nightmare green"; "john bigboote"; "blue hades"; "tsathoggua"; "planet 10";"ia! ia!";"yuggoth";"r'lyeh"; "ei!" |]
*)

let split_str = Str.split (Str.regexp "")

let convert_move s =
    match s with
    | "p" | "'" | "!" | "." | "0" | "3" -> W
    | "b" | "c" | "e" | "f" | "y" | "2" -> E
    | "a" | "g" | "h" | "i" | "j" | "4" -> SW
    | "l" | "m" | "n" | "o" | " " | "5" -> SE
    | "d" | "q" | "r" | "v" | "z" | "1" -> CW
    | _ -> CCW

let phrases = Array.map
    (fun s -> List.map convert_move (split_str s))
    phrases_string

let rec flatten_path path = match path with
    | [] -> ([], [])
    | Single m :: q -> let a, b = flatten_path q
        in (m :: a, b)
    | Power i :: q -> let a, b = flatten_path q
        in (List.rev phrases.(i) @ a, i :: b)

let leaf_score_phrases phrases_list =
    let npow = Array.length phrases in
    let phrase_occ = Array.make npow 0 in
    List.iter (fun i -> phrase_occ.(i) <- phrase_occ.(i) + 1) phrases_list;
    let power_score = ref 0 in
    for i = 0 to npow - 1 do
        power_score := !power_score + 2 * List.length phrases.(i)
                * phrase_occ.(i) 
    done;
    !power_score

let score_phrases phrases_list =
    let npow = Array.length phrases in
    let phrase_occ = Array.make npow 0 in
    List.iter (fun i -> phrase_occ.(i) <- phrase_occ.(i) + 1) phrases_list;
    let power_score = ref 0 in
    for i = 0 to npow - 1 do
        let power_bonus = 
            if phrase_occ.(i) > 0
            then 300 else 0
        in
        let score = 2 * List.length phrases.(i)
                * phrase_occ.(i) + power_bonus in
(*
        Printf.eprintf "Power phrase %s : %d = %d\n"
            phrases_string.(i) phrase_occ.(i) score;
*)
        power_score := !power_score + score
    done;
    !power_score

let string_of_move m = match m with
    | E -> "E"
    | W -> "W"
    | SW -> "SW"
    | SE -> "SE"
    | CW -> "CW"
    | _ -> "CCW"

let string_of_path p =
    String.concat "" (List.map string_of_move  (List.rev p))

let command_of_move m = match m with
    | E -> "b"
    | W -> "p"
    | SW -> "a"
    | SE -> "l"
    | CW -> "d"
    | _ -> "k"

let command_of_path p =
    String.concat "" (List.map command_of_move  (List.rev p))

let can_score_two_lines = ref false
let count_full_lines board =
    let cleared = ref 0 in
    let off_by_one = ref 0 in
    let off_by_two = ref 0 in
    let w, h = Board.dim board in
    for y = h-1 downto 0 do
        let current_in = ref false in
        let count_not_empty = ref 0 in
        for x = 0 to w-1 do
            match board.(x).(y) with
            | CURRENT _ -> current_in := true;
            | EMPTY -> ()
            | _ -> incr count_not_empty
        done;
        match w - !count_not_empty with
        | 0 -> incr cleared
        | 1 when !current_in -> incr off_by_one
        | 2 when !current_in -> incr off_by_two
        | _ -> ()
    done;
    !cleared, !off_by_one, !off_by_two

let count_enclosed board bb pos =
    let w, h = Board.dim board in
    let count = ref 0 in
    for x = max 0 (bb.left-1) to min (w-1) (bb.right+1) do
    for y = max 0 (bb.top-1) to min (h-1) (bb.bottom+1) do
        if board.(x).(y) = EMPTY
        then begin
            let enclosed = ref true in
            if x > 0 && board.(x-1).(y) = EMPTY
            then enclosed := false;
            if x < w-1 && board.(x+1).(y) = EMPTY
            then enclosed := false;
            if y > 0
            then begin
                if board.(x).(y-1) = EMPTY
                then enclosed := false;
                if y mod 2 = 0 && x > 0 && board.(x-1).(y-1) = EMPTY
                then enclosed := false;
                if y mod 2 = 1 && x < w-1 && board.(x+1).(y-1) = EMPTY
                then enclosed := false
            end;
            if !enclosed
            then incr count
        end
    done
    done;
    !count

let count_bottom_empty_neighbours board bb pos =
    let w, h = Board.dim board in
    let count = ref 0 in
    for x = max 0 (bb.left-1) to min (w-1) (bb.right+1) do
        if board.(x).(bb.bottom) = EMPTY
        then incr count
    done;
    !count

let count_weak_enclosed board bb pos =
    let w, h = Board.dim board in
    let count = ref 0 in
    for x = max 0 (bb.left-1) to min (w-1) (bb.right+1) do
    for y = min (h) (bb.top+1) to min (h-1) (bb.bottom+1) do
        if board.(x).(y) = EMPTY
        then begin
            let enclosed = ref 2 in
            if y > 0
            then begin
                if board.(x).(y-1) = EMPTY
                then begin
                    enclosed := 1
                end;
                if y mod 2 = 0 && 
                    ((x > 0 && board.(x-1).(y-1) = EMPTY) || x = 0)
                then begin
                    enclosed := !enclosed - 1
                end;
                if y mod 2 = 1 && 
                    ((x < w-1 && board.(x+1).(y-1) = EMPTY) || x = w-1)
                then begin
                    enclosed := !enclosed - 1
                end;
            end else enclosed := 0;

            count := !count + !enclosed
        end
    done
    done;
    !count


let other_args = 4
let n_pond = 6 + other_args
let pond_delta = if Array.length Sys.argv >= n_pond 
                then - (int_of_string Sys.argv.(other_args+0)) else -3
let pond_h = if Array.length Sys.argv >= n_pond
                then (int_of_string Sys.argv.(other_args+1)) else 2
let pond_enc = if Array.length Sys.argv >= n_pond
                then - (int_of_string Sys.argv.(other_args+2)) else -1
let pond_lin = if Array.length Sys.argv >= n_pond
                then (int_of_string Sys.argv.(other_args+3)) else 100
let pond_pow = if Array.length Sys.argv >= n_pond
                then (int_of_string Sys.argv.(other_args+4)) else 1
let pond_comp = if Array.length Sys.argv >= n_pond
                then -(int_of_string Sys.argv.(other_args+5)) else -100

let score_leaf board bh leaf =
    let pos, full_path = leaf in
    let path, powh = flatten_path full_path in
    let pm = pos.p_members in
    let score_power = leaf_score_phrases powh in
    
    Piece.place board pos;
    (*
    let n_comp = Graph.connected_components board 5 pos in
    *)



    let bb = Geometry.bbox pm in
    let w, h = Board.dim board in
    let delta_inc = bh - bb.top in
    let perc_delta = (100 * delta_inc) / h in
    let perc_h = (100 * bb.bottom) / h in
    let full_lines, off_by_one, off_by_two = count_full_lines board in
    let enclosed = count_weak_enclosed board bb pos in
    let empty = count_bottom_empty_neighbours board bb pos in
    let sz = List.length pos.p_members in
    let perc_empty = (100 * empty) / sz in
    let perc_e = (100 * enclosed) / sz in

    let score = pond_delta*perc_delta 
        + pond_h*perc_h 
        + perc_e*pond_enc
        + 2*perc_empty*pond_enc
        (*
        + pond_comp*(n_comp-1)
        *)
        + (if full_lines >= 1 || (full_lines = 1 && not !can_score_two_lines)
                then pond_lin * full_lines
                else if full_lines = 1 then -pond_lin else 0)
        + (pond_lin* off_by_one)/2
        + (pond_lin * off_by_two)/4
        + pond_pow * score_power in


    (*
    Board.print board;
    Gui.util_text (Printf.sprintf "%d-%d-[%d]-%d-%d+%d+%d+%d+%d = %d"
       perc_h perc_delta n_comp perc_e perc_empty full_lines off_by_one off_by_two score_power score); 
    Gui.pause ();
    *)

    Piece.unplace board pm;

    score

let best_leaf board bh leaves =
    let best_score = ref (score_leaf board bh (List.hd leaves)) in
    let best_leaf = ref (List.hd leaves) in
    List.iter (fun leaf ->
        let scr = score_leaf board bh leaf in
        if scr > !best_score
        then begin
            best_score := scr;
            best_leaf := leaf
        end) (List.tl leaves);
    !best_leaf

exception CantSpawn


let () =
    let p = Data.problem_from_file Sys.argv.(1) in
    
(*
    Printf.eprintf "Problem %d\n" p.id;
    flush stderr;
*)

    (*
    Printf.printf "(%d,[" p.id;
    *)
    Gui.init p.width p.height;
    Gui.pause ();
    (*
    ignore (Unix.select [] [] [] 1.0);
    *)

    for i = 0 to Array.length p.units-1 do
        if List.length p.units.(i).members > 1
        then can_score_two_lines := true
    done;

    let total_score = ref 0 in

    (*
    for i = 0 to Array.length p.sourceSeeds-1 do
    *)

    let phrases_occ = Array.make (Array.length phrases) 0 in

    let i = int_of_string Sys.argv.(3) in


        let board = Board.init p.width p.height p.filled in
        if Gui.interactive
        then Board.print board
        else begin
            Printf.eprintf "%%%% BEGIN Play\n\\begin{tikzpicture}\n";
            Board.print board;
            Printf.eprintf "%%%% END Play\n\\begin{tikzpicture}\n"
        end;
        let seed = (i) in
        (*
        Printf.printf "(%d,\"" seed;
        *)

(*
        Printf.eprintf "Seed %d\n" seed;
        flush stderr;
*)
        Gen.init seed (Array.length p.units);

        let phrases_total = ref [] in
        (*

        let commands = ref [] in
*)
        let score = ref 0 in
        let total_power_score = ref 0 in

        begin try
        for loop = 1 to p.sourceLength do
            let g = Gen.get () in
            let u = p.units.(g) in
            let pi = Piece.spawn u p.width in
            let pm = pi.p_members in

            if not (Piece.fits board pm)
            then raise CantSpawn;

            let ls_old = ref 0 in

(*
            Printf.eprintf "%d/%d\r" loop p.sourceLength;
            flush stderr;
*)

            let board_height = Board.height board in

            Piece.place board pi;
            if Gui.interactive
            then Board.refresh board pm
            else begin
                Printf.eprintf "%%%% BEGIN Spawn %d\n\\begin{tikzpicture}\n" loop;
                Board.print board;
                Gui.plot_point p.height pi.p_pivot;
                Printf.eprintf "\\end{tikzpicture}\n%%%% END Spawn %d\n" loop;
            end;

            Piece.unplace board pm;

            let visited = Array.init
                (20+p.width)
                (fun x -> Array.init (20+p.height) (fun y -> Array.make 6 false))
            in
            let is_visited pos =
                let {x=x;y=y},r = Piece.hash pos in
                visited.(10+x).(10+y).(r)
            in
            let mark_visited pos =
                let {x=x;y=y},r = Piece.hash pos in
                visited.(10+x).(10+y).(r) <- true
            in

            (*
            let visited = ref [] in
            let is_visited pos =
                List.mem (Piece.hash pos) !visited
            in
            let mark_visited pos =
                    visited := (Piece.hash pos) :: !visited;
            in
            *)
            let tovisit = Queue.create () in
            let tovisit = Queue.create () in
            Queue.add (pi,[],[Piece.hash pi]) tovisit;
            let leaves = ref [] in

            while not (Queue.is_empty tovisit) do
                let pos, path, hashes = Queue.take tovisit in
                
                if not (is_visited pos)
                then begin
                    mark_visited pos;

                    Array.iter (fun pow_id ->
                        try
                            let pow = phrases.(pow_id) in
                            let p2, new_hashes = Piece.move_pow board hashes
                                pos pow [pos] in
                            Queue.add 
                                (p2, Power pow_id :: path, new_hashes @ hashes) tovisit
                        with Piece.InvalidPow -> ()
                    ) (Array.init (Array.length phrases) (fun i -> i));

                    let invalid_moves =  ref [] in
                    List.iter (fun m ->
                        let p2 = Piece.move pos m in
                        if Piece.fits board p2.p_members
                        then (if not (List.mem (Piece.hash p2) hashes)
                            then Queue.add (p2, Single m::path, Piece.hash p2 :: hashes) tovisit) 
                        else invalid_moves := m::!invalid_moves)
                            (*
                                 T
                                 |
                                 B
                             
                                 <-- height
                             *)
                            [ E; W; SE; SW; CW; CCW ];

                    if !invalid_moves <> []
                    then begin
                        let bb = Geometry.bbox pos.p_members in
                        if bb.bottom >= board_height-1 &&
                            not (List.exists (fun (p,_) -> Piece.eq pos p) !leaves)
                        then leaves := 
                                (pos, Single (List.hd (!invalid_moves)) :: path) :: !leaves
                    end
                end
            done;

            let pos, full_path = best_leaf board board_height !leaves in

            let path, powph = flatten_path full_path in

            (* Printf.eprintf "Path %s\n" (string_of_path path); *)
            let rpos = ref pi in
            let wait_time = 25.0 in
            let step = ref 0 in
            if Gui.interactive
            then Board.refresh board pm;
            List.iter (fun exm -> 
                match exm with
                | Single m ->
                    incr step;
                    if Gui.interactive
                    then begin
                        Gui.wait wait_time;
                        Board.refresh board !rpos.p_members;
                    end;
                    rpos := Piece.move !rpos m;
                    Piece.place board !rpos;
                    if Gui.interactive
                    then Board.refresh board !rpos.p_members
                    else begin
                        Printf.eprintf "%%%% BEGIN Step %d\n\\begin{tikzpicture}\n" !step;
                        Board.print board;
                        Gui.plot_point p.height !rpos.p_pivot;
                        Printf.eprintf "%%%% END Step %d\n\\end{tikzpicture}\n" !step;
                    end;
                    (* Board.print board; *)
                    Piece.unplace board !rpos.p_members;
                | Power i ->
                    let p = phrases.(i) in
                    let pt = phrases_string.(i) in
                    phrases_occ.(i) <- 1 + phrases_occ.(i);
                    Gui.bonus_text 
                        (string_of_int phrases_occ.(i) ^ "x " ^ pt);
                    List.iter (fun m ->
                        incr step;
                        if Gui.interactive
                        then begin
                            Gui.wait wait_time;
                            Board.refresh board !rpos.p_members
                        end;
                        rpos := Piece.move !rpos m;
                        Piece.place board !rpos;
                        if Gui.interactive
                        then Board.refresh board !rpos.p_members
                        else begin
                            Printf.eprintf "%%%% BEGIN Step %d\n\\begin{tikzpicture}\n" !step;
                            Board.print board;
                            Gui.plot_point 0 !rpos.p_pivot;
                            Printf.eprintf "%%%% END Step %d\n\\end{tikzpicture}\n" !step;
                        end;
                        (* Board.print board; *)
                        Piece.unplace board !rpos.p_members)
                        p;
                    Gui.bonus_text  ""
                ) (List.rev (List.tl full_path));

            Piece.lock board pos;
            if Gui.interactive
            then Board.refresh board pos.p_members;

            Printf.printf "%s\n" (command_of_path path);
            flush stdout;

            (* commands := path @ !commands;*)

            let ls = Board.clear board in
            let size = List.length u.members in
            let points = size + 100 * (1 + ls) * ls / 2 in
            let line_bonus = if !ls_old > 1
                then ( (!ls_old -1) * points ) / 10
                else 0 in

            let move_score = points + line_bonus in
            score := !score + move_score;
            phrases_total := powph @ !phrases_total;
            let sub_power_score = score_phrases !phrases_total in
            Gui.score !score move_score sub_power_score;
            
            if ls > 0 
            then begin
                if Gui.interactive
                then Board.print board
                else begin
                    Printf.eprintf "%%%% BEGIN Clear %d\n\\begin{tikzpicture}\n" ls;
                    Board.print board;
                    Printf.eprintf "%%%% END Clear\n\\end{tikzpicture}\n"
                end
            end;
            (* Gui.flush p.id seed; *)
            (* Piece.unplace board pi.p_members;*)
            (* Gui.plot_point p.height pos.p_pivot; *)
        done;
            raise CantSpawn
        with CantSpawn -> 
            let power_score = score_phrases !phrases_total in

            Printf.eprintf "<- P%d S%d SCR %d+%d=%d\n" 
                p.id seed        
                !score power_score (!score+power_score);
            flush stderr;

            (*
            Printf.printf "\"),";
            *)
            total_score := !total_score + !score + power_score
    end;
    (*
    done;
    *)
    (*
    Printf.printf "])\n";
    *)
    Gui.pause ();
    Gui.close ()

