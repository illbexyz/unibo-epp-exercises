-module(philosophers) .
-export([main/0, table/2, philosopher/5]) .

table(L, Pending) ->
    Process_pending =
        fun
            Aux([]) -> ko ;
            Aux([{ get, Phil, X, Y } | TL]) ->
                case lists:member(X, L) and lists:member(Y, L) of
                    true ->
                        Phil ! ok,
                        { ok, L -- [X], Pending -- [TL]} ;
                    false ->
                        Aux(TL)
                end
        end ,
    case Process_pending(Pending) of
        {ok, L2, Pending2} ->
            table(L2, Pending2) ;
        ko ->
            receive
                T = { get, Phil, X, Y } ->
                    case lists:member(X, L) of
                        true ->
                            Phil ! ok,
                            table(L -- [X, Y], Pending) ;
                        false ->
                            table(L, [T | Pending])
                    end ;
                { free, X, Y } ->
                    table([X, Y | L], Pending)
            end
    end .

% get_fork(Table, X) ->
%     Table ! { get, self(), X },
%     receive ok -> ok end .

get_forks(Table, X) ->
    Table ! {get, self(), X, (X+1) rem 5},
    receive ok -> ok end .

% release_fork(Table, X) ->
%     Table ! {free, X} .

release_forks(Table, X) ->
    Table ! {free, X, (X+1) rem 5} .

% sleep(N) ->
%     receive after N * 1000 -> ok end .

philosopher(Main, Table, N, MaxIterations, Iteration) when Iteration < MaxIterations->
    io:format("~p - ~p thinks~n", [Iteration, N]),
    % sleep(rand:uniform(3)),
    io:format("~p - ~p is hungry~n", [Iteration, N]),
    get_forks(Table, N),
    io:format("~p - ~p eats~n", [Iteration, N]),
    % sleep(rand:uniform(2)),
    release_forks(Table, N),
    philosopher(Main, Table, N, MaxIterations, Iteration + 1) ;

philosopher(Main, _, _, _, _) -> Main ! exit .

main() ->
    SEQ = lists:seq(0,4),
    Table = spawn(?MODULE, table, [SEQ, []]),
    [ spawn(?MODULE, philosopher, [self(), Table, Phil, 1000000000, 0]) || Phil <- SEQ],
    [ receive exit -> io:format("Bye bye~n") end || _ <- SEQ ].