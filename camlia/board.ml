open Common_types

let dim b = (Array.length b, Array.length b.(0))

let height b =
    let w, h = dim b in
    let height = ref (h-1) in
    for y = 0 to h-1 do
    for x = 0 to w-1 do
        if b.(x).(y) <> EMPTY && y < !height
        then height := y
    done
    done;
    !height

let init w h filled = 
    let b = Array.make_matrix w h EMPTY in
    List.iter (fun c -> b.(c.x).(c.y) <- FILLED) filled;
    b

let string_of_cell c = match c with
    EMPTY -> "." | LOCKED _ -> "#" | CURRENT _ -> "O" | FILLED -> "*"

let refresh b l =
    let h = Array.length b.(0) in
    List.iter (fun c -> Gui.plot_cell h c b.(c.x).(c.y))
        l

let print b =
    let w = Array.length b in
    let h = Array.length b.(0) in
    Gui.start_board w h;
    for y = 0 to h-1 do
        for x = 0 to w-1 do
            Gui.plot_cell h {x=x;y=y} b.(x).(y)
        done
    done;
    Gui.end_board ()
    (*
        if shift
        then print_string " ";
        for x = 0 to w-1 do
            print_string (string_of_cell b.(x).(y) ^ " ")
        done;
        print_newline ()
    done;
    print_newline ()
    *)

let clear b =
    let cleared = ref 0 in

    let w, h = dim b in

    let y = ref (h-1) in
    while !y >= 0 do
        let full = ref true in
        for x = 0 to w-1 do
            if b.(x).(!y) = EMPTY
            then full := false
        done;
        if !full
        then begin
            incr cleared;
            for ny = !y downto 1 do
                for x = 0 to w-1 do
                    b.(x).(ny) <- b.(x).(ny-1)
                done
            done;
            for x = 0 to w-1 do
                b.(x).(0) <- EMPTY
            done
        end else y := !y - 1
    done;

    !cleared

