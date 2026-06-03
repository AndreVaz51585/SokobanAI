:- module(sokoban_board, [
    print_board/1
]).

print_board([]).

print_board([Row | Rest]) :-
    print_row(Row),
    nl,
    print_board(Rest).

print_row([]).

print_row([Cell | Rest]) :-
    write(Cell),
    print_row(Rest).
