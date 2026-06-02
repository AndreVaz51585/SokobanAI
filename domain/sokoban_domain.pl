:- module(sokoban_domain, [
    can/2,
    adds/2,
    deletes/2,
    impossible/2,
    start/1,
    wall/2,
    direction/3,
    valid_position/2,
    goal_cell/2
]).

:- use_module(library(clpfd)).




wall(0,0). wall(0,1). wall(0,2). wall(0,3). wall(0,4).
wall(1,0).                               wall(1,4).
wall(2,0).                               wall(2,4).
wall(3,0).                               wall(3,4).
wall(4,0). wall(4,1). wall(4,2). wall(4,3). wall(4,4).

% Example goal position for the query:
% bestfirst([at_player(3,2)] -> stop, Plan).


% start([
%     at_player(1,2),
%     box(2,2),
%     free(1,1), free(1,3),
%     free(2,1), free(2,3),
%     free(3,1), free(3,2), free(3,3)
% ]).

% estado dinamico inicial, aquilo que pode ser alterado durante a resolução.
% start([
%    at_player(1,1),
%    box(b1,2,2),
%    box(b2,2,3),
%    free(1,2), free(1,3),
%    free(2,1),
%    free(3,1), free(3,2), free(3,3)
% ]).

start([
    at_player(2,2),
    box(b1,2,1),
    free(1,1), free(1,2), free(1,3),
    free(2,3),
    free(3,1), free(3,2), free(3,3)
]).


% goal_cell(3, 2).
goal_cell(3, 3).

direction(north, -1, 0).
direction(south,  1, 0).
direction(west,   0, -1).
direction(east,   0, 1).

valid_position(Row, Col) :-
    Row >= 0,
    Col >= 0,
    \+ wall(Row, Col).


can(move(Direction, Row, Col, NewRow, NewCol), [
    at_player(Row, Col),
    free(NewRow,NewCol)
]) :-
    direction(Direction, DRow, DCol),
    NewRow #= Row + DRow,
    NewCol #= Col + DCol,
    valid_position(Row, Col),
    valid_position(NewRow, NewCol).



adds(move(_, Row, Col, NewRow, NewCol), [
    at_player(NewRow, NewCol),
    free(Row,Col)
]).

deletes(move(_, Row, Col, NRow, NCol), [
    at_player(Row, Col),
    free(NRow,NCol)
]).


wall_above_or_below(Row, Col) :-
    Above is Row - 1,
    wall(Above, Col).

wall_above_or_below(Row, Col) :-
    Below is Row + 1,
    wall(Below, Col).

wall_left_or_right(Row, Col) :-
    Left is Col - 1,
    wall(Row, Left).

wall_left_or_right(Row, Col) :-
    Right is Col + 1,
    wall(Row, Right).


corner_deadlock(Row, Col) :-
    wall_above_or_below(Row, Col),
    wall_left_or_right(Row, Col).

not_deadlock(Row, Col) :-
    goal_cell(Row, Col), !.

not_deadlock(Row, Col) :-
    \+ corner_deadlock(Row, Col).





can(push(Direction,Row,Col,BoxId,BoxRow,BoxCol,NewBoxRow,NewBoxCol), [
    at_player(Row,Col),
    box(BoxId,BoxRow,BoxCol),
    free(NewBoxRow,NewBoxCol)
]) :-
    direction(Direction,DRow,DCol),

    BoxRow #= Row + DRow,
    BoxCol #= Col + DCol,

    NewBoxRow #= BoxRow + DRow,
    NewBoxCol #= BoxCol + DCol,

    valid_position(Row,Col),
    valid_position(BoxRow,BoxCol),
    valid_position(NewBoxRow,NewBoxCol),
    not_deadlock(NewBoxRow, NewBoxCol).


adds(push(_,Row,Col,BoxId,BoxRow,BoxCol,NewBoxRow,NewBoxCol), [
    free(Row,Col),
    at_player(BoxRow,BoxCol),
    box(BoxId,NewBoxRow,NewBoxCol)
]).

deletes(push(_,Row,Col,BoxId,BoxRow,BoxCol,NewBoxRow,NewBoxCol), [
    free(NewBoxRow,NewBoxCol),
    at_player(Row,Col),
    box(BoxId,BoxRow,BoxCol)
]).



impossible(at_player(Row, Col), _) :-

    wall(Row, Col).

impossible(box(BoxId,Row, Col), _) :-

    wall(Row, Col).

impossible(free(Row, Col), _) :-

    wall(Row, Col).

% Player cannot be in two positions.

impossible(at_player(Row, Col), Goals) :-

    member(at_player(Row2, Col2), Goals),

    (Row \== Row2 ; Col \== Col2).

% Box cannot be in two positions.

impossible(box(BoxId,Row, Col), Goals) :-

    member(box(BoxId,Row2, Col2), Goals),

    (Row \== Row2 ; Col \== Col2).

% A cell cannot be free and occupied by player.

impossible(free(Row, Col), Goals) :-

    member(at_player(Row, Col), Goals).

impossible(at_player(Row, Col), Goals) :-

    member(free(Row, Col), Goals).

% A cell cannot be free and occupied by box.

impossible(free(Row, Col), Goals) :-

    member(box(BoxId,Row, Col), Goals).

impossible(box(BoxId,Row, Col), Goals) :-

    member(free(Row, Col), Goals).

% Player and box cannot occupy same cell.

impossible(at_player(Row, Col), Goals) :-

    member(box(BoxId,Row, Col), Goals).

impossible(box(BoxId,Row, Col), Goals) :-

    member(at_player(Row, Col), Goals).