:- module(sokoban_domain, [
    can/2,
    adds/2,
    deletes/2,
    impossible/2,
    start/1,
    wall/2,
    direction/3,
    valid_position/2
]).

:- use_module(library(clpfd)).




wall(0,0). wall(0,1). wall(0,2). wall(0,3). wall(0,4).
wall(1,0).                               wall(1,4).
wall(2,0).                               wall(2,4).
wall(3,0).                               wall(3,4).
wall(4,0). wall(4,1). wall(4,2). wall(4,3). wall(4,4).

% Example goal position for the query:
% bestfirst([at_player(3,2)] -> stop, Plan).


start([
    at_player(1,2)
]).


direction(north, -1, 0).
direction(south,  1, 0).
direction(west,   0, -1).
direction(east,   0, 1).

valid_position(Row, Col) :-
    Row >= 0,
    Col >= 0,
    \+ wall(Row, Col).


can(move(Direction, Row, Col, NewRow, NewCol), [
    at_player(Row, Col)
]) :-
    direction(Direction, DRow, DCol),
    NewRow #= Row + DRow,
    NewCol #= Col + DCol,
    valid_position(Row, Col),
    valid_position(NewRow, NewCol).

adds(move(_, _, _, NewRow, NewCol), [
    at_player(NewRow, NewCol)
]).

deletes(move(_, Row, Col, _, _), [
    at_player(Row, Col)
]).


% Player cannot be inside a wall.
impossible(at_player(Row, Col), _) :-
    wall(Row, Col).

% Player cannot be in two different positions at the same time.
impossible(at_player(Row, Col), Goals) :-
    member(at_player(Row2, Col2), Goals),
    (Row \== Row2 ; Col \== Col2).