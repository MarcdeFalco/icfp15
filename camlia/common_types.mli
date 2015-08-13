type cell = { x : int; y : int }
type bbox = { left: int; right: int; top: int; bottom: int }
type unt = { members: cell list; pivot : cell; 
    symmetry : int; bboxes: bbox array; id : int }
type problem = { units: unt array; id: int;
    width:int; height:int;
    filled: cell list;
    sourceLength: int; sourceSeeds: int array }
type transformation = int
type cell_state = EMPTY | FILLED | LOCKED of int | CURRENT of int
type board = cell_state array array
type piece = { unt:unt; p_pivot:cell; trans: transformation; p_members: cell list }
type movement = E | W | SE | SW | CW | CCW
