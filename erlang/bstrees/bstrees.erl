-module(bstrees).
-export([main/0]).

foldl(_F, R, []) -> R ;
foldl(F, R, [H | TL]) -> foldl(F, F(H, R), TL).

empty() -> nil.

insert(K, nil) -> {node, K, nil, nil} ;
insert(K, {node, K1, L, R}) when K < K1 -> {node, K1, insert(K, L), R} ;
insert(K, {node, K1, L, R}) when K > K1 -> {node, K1, L, insert(K, R)} ;
insert(_, T) -> T .

%----------------------------------------------------------------------%
% Write remove and append functions
% Write an additional append function using foldl
%----------------------------------------------------------------------%

append(nil, T2) -> T2 ;
append(T1, nil) -> T1 ;
append(T1, {node, K, L, R}) -> append(append(insert(K, T1), L), R) .

keys(nil, LS) -> LS;
keys({node, K, L, R}, LS) -> keys(R, keys(L, [K | LS])) .
keys(T) -> keys(T, []).

append_fold(nil, T2) -> T2 ;
append_fold(T1, nil) -> T1 ;
append_fold(T1, T2) -> foldl(fun insert/2, T1, keys(T2)) .

remove(_, nil) -> nil ;
remove(K, {node, K1, L, R}) when K < K1 -> {node, K1, remove(K, L), R} ;
remove(K, {node, K1, L, R}) when K > K1 -> {node, K1, L, remove(K, R)} ;
remove(_, {node, _, L, R}) -> append(R, L) .

main() ->
    % foldl(fun insert/2, empty(), [4, 0, 9, 3, 1, 12, 11, 15]) .
    % insert(3, insert(0, empty())) .
    remove(9, foldl(fun insert/2, empty(), [4, 0, 9, 3, 1, 12, 11, 15])) .
    % append(nil, nil) .
    % append_fold(insert(0, empty()), foldl(fun insert/2, empty(), [4, 0, 9, 3, 1, 12, 11, 15])) .
    % keys(foldl(fun insert/2, empty(), [4, 0, 9, 3, 1, 12, 11, 15])) .
