:- use_module(library(readutil), [read_line_to_string/2]).

:- use_module('board/board.pl').
:- use_module('player/player.pl').
:- use_module('executor/executor').
:- use_module('domain/sokoban_domain', []).

:- consult('planner/goal_regression_best_search.pl').

puzzle(facil, 'Facil', [
    ['#','#','#','#','#'],
    ['#','@',' ',' ','#'],
    ['#',' ','$',' ','#'],
    ['#',' ','.',' ','#'],
    ['#','#','#','#','#']
]).

puzzle(intermedio, 'Intermedio', [
    ['#','#','#','#','#'],
    ['#','@',' ',' ','#'],
    ['#',' ','$','$','#'],
    ['#',' ','.','.','#'],
    ['#','#','#','#','#']
]).

puzzle(dificil, 'Dificil', [
    ['#','#','#','#','#','#','#'],
    ['#','@',' ',' ',' ',' ','#'],
    ['#',' ','#','#','#',' ','#'],
    ['#',' ',' ',' ',' ',' ','#'],
    ['#',' ','$','$',' ',' ','#'],
    ['#',' ','.','.',' ',' ','#'],
    ['#','#','#','#','#','#','#']
]).

test_board(Board) :-
    puzzle(intermedio, _, Board),
    setup_puzzle(Board).

main :-
    run.

run :-
    choose_difficulty(Difficulty),
    run_puzzle(Difficulty).

run_puzzle(Difficulty) :-
    puzzle(Difficulty, Name, Board),
    setup_puzzle(Board),
    nl,
    write('Nivel selecionado: '), write(Name), nl,
    write('Tabuleiro inicial:'), nl,
    print_board(Board),
    statistics(runtime, [StartTime | _]),
    (   solve_actions(Actions)
    ->  statistics(runtime, [EndTime | _]),
        Runtime is EndTime - StartTime,
        length(Actions, ActionCount),
        nl,
        write('Plano encontrado com '), write(ActionCount), write(' acoes.'), nl,
        write('Tempo de planeamento: '), write(Runtime), write(' ms'), nl,
        write('Acoes: '), write(Actions), nl,
        execute_plan(Board, Actions, FinalBoard),
        nl,
        write('Tabuleiro final:'), nl,
        print_board(FinalBoard)
    ;   statistics(runtime, [EndTime | _]),
        Runtime is EndTime - StartTime,
        nl,
        write('Nao foi encontrado plano para este nivel.'), nl,
        write('Tempo de tentativa: '), write(Runtime), write(' ms'), nl
    ),
    !.

choose_difficulty(Difficulty) :-
    nl,
    write('Escolhe o nivel de Sokoban:'), nl,
    write('1 - Facil'), nl,
    write('2 - Intermedio'), nl,
    write('3 - Dificil'), nl,
    write('Opcao: '),
    read_line_to_string(user_input, Choice),
    difficulty_choice(Choice, Difficulty), !.

choose_difficulty(Difficulty) :-
    nl,
    write('Opcao invalida.'), nl,
    choose_difficulty(Difficulty).

difficulty_choice("1", facil).
difficulty_choice("1.", facil).
difficulty_choice("2", intermedio).
difficulty_choice("2.", intermedio).
difficulty_choice("3", dificil).
difficulty_choice("3.", dificil).
difficulty_choice("facil", facil).
difficulty_choice("facil.", facil).
difficulty_choice("intermedio", intermedio).
difficulty_choice("intermedio.", intermedio).
difficulty_choice("dificil", dificil).
difficulty_choice("dificil.", dificil).

setup_puzzle(Board) :-
    retractall(sokoban_domain:start(_)),
    retractall(sokoban_domain:wall(_, _)),
    retractall(sokoban_domain:goal_cell(_, _)),
    load_rows(Board, 0, 1, [], StartFacts),
    reverse(StartFacts, Start),
    assertz(sokoban_domain:start(Start)).

load_rows([], _, BoxCounter, StartFacts, StartFacts) :-
    BoxCounter >= 1.

load_rows([Row | Rows], RowIndex, BoxCounter, StartAcc, StartFacts) :-
    load_cells(Row, RowIndex, 0, BoxCounter, NextBoxCounter, StartAcc, NextStartAcc),
    NextRowIndex is RowIndex + 1,
    load_rows(Rows, NextRowIndex, NextBoxCounter, NextStartAcc, StartFacts).

load_cells([], _, _, BoxCounter, BoxCounter, StartFacts, StartFacts).

load_cells([Cell | Cells], Row, Col, BoxCounter, FinalBoxCounter, StartAcc, StartFacts) :-
    load_cell(Cell, Row, Col, BoxCounter, NextBoxCounter, StartAcc, NextStartAcc),
    NextCol is Col + 1,
    load_cells(Cells, Row, NextCol, NextBoxCounter, FinalBoxCounter, NextStartAcc, StartFacts).

load_cell('#', Row, Col, BoxCounter, BoxCounter, StartFacts, StartFacts) :-
    assertz(sokoban_domain:wall(Row, Col)).

load_cell('@', Row, Col, BoxCounter, BoxCounter, StartFacts, [at_player(Row, Col) | StartFacts]).

load_cell('+', Row, Col, BoxCounter, BoxCounter, StartFacts, [at_player(Row, Col) | StartFacts]) :-
    assertz(sokoban_domain:goal_cell(Row, Col)).

load_cell('$', Row, Col, BoxCounter, NextBoxCounter, StartFacts, [box(BoxId, Row, Col) | StartFacts]) :-
    box_id(BoxCounter, BoxId),
    NextBoxCounter is BoxCounter + 1.

load_cell('*', Row, Col, BoxCounter, NextBoxCounter, StartFacts, [box(BoxId, Row, Col) | StartFacts]) :-
    assertz(sokoban_domain:goal_cell(Row, Col)),
    box_id(BoxCounter, BoxId),
    NextBoxCounter is BoxCounter + 1.

load_cell('.', Row, Col, BoxCounter, BoxCounter, StartFacts, [free(Row, Col) | StartFacts]) :-
    assertz(sokoban_domain:goal_cell(Row, Col)).

load_cell(' ', Row, Col, BoxCounter, BoxCounter, StartFacts, [free(Row, Col) | StartFacts]).

box_id(Number, BoxId) :-
    atomic_list_concat([b, Number], BoxId).

:- initialization(main, main).
