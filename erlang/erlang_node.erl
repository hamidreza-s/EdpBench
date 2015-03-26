-module(erlang_node).
-compile(export_all).

-define(
   MSG(ByteSize), 
   list_to_binary([ 255 || _ <- lists:seq(1, ByteSize)])
).

connect(Node) ->
   net_adm:ping(Node).

send({Node, Process}, Msg) ->
   {Process, Node} ! {self(), Msg},
   receive {_, _} -> ok end.

benchmark(NodeProcess, MsgSize, Count) ->
   State1 = [],
   State2 = lists:append(State1, [{start_time, now()}]),
   do_benchmark(NodeProcess, ?MSG(MsgSize), State2, Count).

do_benchmark(NodeProcess, Msg, State, Count) when Count > 0 ->
   send(NodeProcess, Msg),
   do_benchmark(NodeProcess, Msg, State, Count - 1);
do_benchmark(NodeProcess, Msg, State, _Count) ->
   report(NodeProcess, Msg, State),
   done.

report({Node, Process}, Msg, State) ->
   EndTime = now(),
   StartTime = proplists:get_value(start_time, State),
   TimeDuration = timer:now_diff(EndTime, StartTime),
   error_logger:info_msg(
      "Done in ~p microseconds.~nNode: ~p - process: ~p~nMsg size: ~p~n~n", 
      [TimeDuration, Node, Process, byte_size(Msg)]
   ).
