:- module(executor, [
    apply_action/3,
    apply_push/3,
    execute_plan/3
]).

:- use_module('../player/player').
:- use_module('../board/board').

apply_action(Board, move(Direction, _, _, _, _), NewBoard) :-
    apply_move(Board, Direction, NewBoard).

apply_action(Board, push(Direction, Row, Col, BoxId, BoxRow, BoxCol, NewBoxRow, NewBoxCol), NewBoard) :-
    apply_push(Board, push(Direction, Row, Col, BoxId, BoxRow, BoxCol, NewBoxRow, NewBoxCol), NewBoard).


apply_push(Board, push(_, PlayerRow, PlayerCol, _BoxId, BoxRow, BoxCol, NewBoxRow, NewBoxCol), NewBoard) :-
    empty_cell_for_position(PlayerRow, PlayerCol, OldPlayerCell),
    player_destination_symbol(BoxRow, BoxCol, NewPlayerCell),
    box_destination_symbol(NewBoxRow, NewBoxCol, NewBoxCell),

    replace_cell(Board, PlayerRow, PlayerCol, OldPlayerCell, Board1),
    replace_cell(Board1, BoxRow, BoxCol, NewPlayerCell, Board2),
    replace_cell(Board2, NewBoxRow, NewBoxCol, NewBoxCell, NewBoard).


execute_plan(Board, [], Board).

execute_plan(Board, [Action | Rest], FinalBoard) :-
    apply_action(Board, Action, NewBoard),
    nl,
    write('Action: '), write(Action), nl,
    print_board(NewBoard),
    execute_plan(NewBoard, Rest, FinalBoard).