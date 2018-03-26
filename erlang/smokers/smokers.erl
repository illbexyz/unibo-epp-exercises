-module(smokers).
-export([main/0, smoker/4, agent/2, table/1]).

sleep(N) ->
    receive after N * 1000 -> ok end .

% Smoker
send_to_agent(AgentPid, Obj) ->
    AgentPid ! Obj .

smoker(MainPid, TablePid, N, Iteration) ->
    receive
        { get, AgentPid } ->
            case N of
                1 -> send_to_agent(AgentPid, { obj, tobacco, self() }) ;
                2 -> send_to_agent(AgentPid, { obj, paper, self() }) ;
                3 -> send_to_agent(AgentPid, { obj, match, self() })
            end;
        { smoke, AgentPid } ->
            TablePid ! { get_from_table },
            io:format("~p - smoker ~p: smoking~n", [Iteration, N]),
            sleep(1),
            AgentPid ! { smoked, self() },
            MainPid ! { smoked, self() }
    end,
    smoker(MainPid, TablePid, N, Iteration - 1) .

% Agent
request_smoker(Pid) ->
    Pid ! { get, self() },
    receive { obj, Obj, Pid } -> { obj, Obj } end .

send_table(TablePid, { obj, Obj }) ->
    TablePid ! { obj, Obj } .

wake_smoker(SmokerPid) ->
    SmokerPid ! { smoke, self() } .

wait_smoker(SmokerPid) ->
    receive { smoked, SmokerPid } -> ok end .

agent(SmokerPids, TablePid) ->
    FirstPid = lists:nth(rand:uniform(3), SmokerPids),
    SecondPid = lists:nth(rand:uniform(2), SmokerPids -- [FirstPid]),
    io:format("agent: requesting to ~p~n", [FirstPid]),
    io:format("agent: requesting to ~p~n", [SecondPid]),
    FirstObj = request_smoker(FirstPid),
    SecondObj = request_smoker(SecondPid),
    io:format("agent: got ~p~n", [FirstObj]),
    io:format("agent: got ~p~n", [SecondObj]),
    send_table(TablePid, FirstObj),
    send_table(TablePid, SecondObj),
    RemainingSmokerPid = lists:nth(1, SmokerPids -- [FirstPid, SecondPid]),
    io:format("agent: waking up smoker ~p~n", [RemainingSmokerPid]),
    wake_smoker(RemainingSmokerPid),
    wait_smoker(RemainingSmokerPid),
    agent(SmokerPids, TablePid) .

% Table
wait_object(State) ->
    receive { obj, Obj } -> [Obj | State] end .

wait_smoker() ->
    receive { get_from_table } -> [] end .

table(State) ->
    case State of
        []      -> table(wait_object(State));
        [_]     -> table(wait_object(State));
        [_, _]  -> table(wait_smoker())
    end .

main() ->
    TablePid = spawn(?MODULE, table, [[]]) ,
    SmokerPids = [ spawn(?MODULE, smoker, [self(), TablePid, I, 5]) || I <- lists:seq(1, 3)] ,
    spawn(?MODULE, agent, [SmokerPids, TablePid]),
    [ receive { smoked, _N } -> ok end || _ <- lists:seq(1, 5) ] .