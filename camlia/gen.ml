
type gen = { mutable current : int; mutable bounds : int }

let the_gen_ = { current=0; bounds =0 }

let init s b = the_gen_.current <- s; the_gen_.bounds <- b

let get () = 
    let v = (the_gen_.current asr 16) land 0x7fff in
    let nc = (the_gen_.current * 1103515245 + 12345) land 0xffffffff in
    the_gen_.current <- nc;
    v mod the_gen_.bounds
