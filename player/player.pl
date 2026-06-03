:- module(player, [
    find_player/3,
    find_box/3,
    is_box/3,
    is_goal_cell/2,
    empty_cell_for_position/3,
    box_on_goal/3,
    all_boxes_on_goals/1,
    player_destination_symbol/3,
    box_destination_symbol/3,
    move_validator/2,
    apply_move/3,
    cell_at/4,
    replace_cell/5,
    replace_in_list/4
]).


:- use_module('../domain/sokoban_domain', [goal_cell/2]).



check_goal(Board):-
    find_player(Board , PRow, PCol),
    goal_cell(PRow,PCol).



find_player(Board, Row, Col) :-
    nth0(Row, Board, BoardRow),
    nth0(Col, BoardRow, Cell),
    (Cell = '@' ; Cell = '+').


% direction(+Direction, -DeltaRow, -DeltaCol)

direction(north, -1, 0).
direction(south,  1, 0).
direction(west,   0, -1).
direction(east,   0, 1).


move_validator(Board, Direction) :-
    find_player(Board, PRow, PCol),
    direction(Direction, DRow, DCol),
    NewRow is PRow + DRow,
    NewCol is PCol + DCol,
    cell_at(Board, NewRow, NewCol,Cell),
    (Cell = ' ' ; Cell = '.').


apply_move(Board,Direction,NewBoard) :-
    move_validator(Board,Direction),
    find_player(Board, PRow, PCol),
    direction(Direction, DRow, DCol),
    NewRow is PRow + DRow,
    NewCol is PCol + DCol,
    empty_cell_for_position(PRow, PCol, OldPlayerCell),
    player_destination_symbol(NewRow, NewCol, NewPlayerCell),
    replace_cell(Board, PRow, PCol, OldPlayerCell, RemovedBoard),
    replace_cell(RemovedBoard, NewRow, NewCol, NewPlayerCell, NewBoard).


    


cell_at(Board, Row, Col, Cell) :-
    nth0(Row, Board, BoardRow),
    nth0(Col, BoardRow, Cell).



replace_cell(Board, Row, Col, NewCell, NewBoard):-
       nth0(Row, Board, OldBoardRow),
       replace_in_list(OldBoardRow, Col, NewCell, NewBoardRow),
       replace_in_list(Board, Row, NewBoardRow, NewBoard).



replace_in_list([_ | Tail], 0, NewElement, [NewElement | Tail]).


replace_in_list([Head | Tail], Index, NewElement, [Head | NewTail]) :-
    Index > 0,
    NextIndex is Index - 1,
    replace_in_list(Tail, NextIndex, NewElement, NewTail).



is_goal_cell(Row, Col) :-
    goal_cell(Row, Col).


empty_cell_for_position(Row, Col, '.') :-
    is_goal_cell(Row, Col), !.

empty_cell_for_position(_, _, ' ').


find_box(Board, Row, Col) :-
    nth0(Row, Board, BoardRow),
    nth0(Col, BoardRow, Cell),
    (Cell = '$' ; Cell = '*').


is_box(Board, Row, Col) :-
    cell_at(Board, Row, Col, Cell),
    (Cell = '$' ; Cell = '*').


% box_on_goal(+Board, +Row, +Col)
box_on_goal(Board, Row, Col) :-
    is_box(Board, Row, Col),
    is_goal_cell(Row, Col).


all_boxes_on_goals(Board) :-
    \+ (
        find_box(Board, Row, Col),
        \+ is_goal_cell(Row, Col)
    ).


player_destination_symbol(Row, Col, '+') :-
    is_goal_cell(Row, Col), !.

player_destination_symbol(_, _, '@').


box_destination_symbol(Row, Col, '*') :-
    is_goal_cell(Row, Col), !.

box_destination_symbol(_, _, '$').
