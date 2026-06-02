:- module(player, [
    find_player/3,
    move_validator/2,
    apply_move/3,
    cell_at/4,
    replace_cell/5,
    replace_in_list/4
    check_goal/1
]).


% Example goals
goal(3, 2).
goal(4, 5).



check_goal(Board):-
    find_player(Board , PRow, PCol),
    goal(PRow,PCol).






find_player(Board, Row, Col) :-
    nth0(Row, Board, BoardRow),
    nth0(Col, BoardRow, '@').


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
    Cell \== '#'.


apply_move(Board,Direction,NewBoard) :-
    move_validator(Board,Direction),
    find_player(Board, PRow, PCol),
    direction(Direction, DRow, DCol),
    NewRow is PRow + DRow,
    NewCol is PCol + DCol,
    replace_cell(Board, PRow, PCol, ' ', RemovedBoard),
    replace_cell(RemovedBoard, NewRow, NewCol,'@', NewBoard).


    


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





