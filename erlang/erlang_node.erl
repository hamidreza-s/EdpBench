-module(erlang_node).
-compile(export_all).

-define(
   MSG(ByteSize), 
   list_to_binary([ 255 || _ <- lists:seq(1, ByteSize)])
).

start() ->
   log("==> erlang node started~n", []),
   benchmark({?REMOTE_NODE, ?REMOTE_PROCESS}, ?MSG_SIZE, ?MSG_COUNT).

connect(Node) ->
   case net_adm:ping(Node) of
      pong -> ok;
      pang ->
         log("~p is not accessible.~n", [Node]),
         nok
   end.

send({Node, Process}, Msg) ->
   {Process, Node} ! {self(), Msg},
   receive {_, _} -> ok end.

benchmark({Node, Process}, MsgSize, Count) ->
   ok = connect(Node),
   State1 = [],
   State2 = lists:append(State1, [{start_time, now()}]),
   State3 = lists:append(State2, [{msg_count, Count}]),
   do_benchmark({Node, Process}, ?MSG(MsgSize), State3, Count).

do_benchmark(NodeProcess, Msg, State, Count) when Count > 0 ->
   send(NodeProcess, Msg),
   do_benchmark(NodeProcess, Msg, State, Count - 1);
do_benchmark(NodeProcess, Msg, State, _Count) ->
   report(NodeProcess, Msg, State),
   done.

report({Node, Process}, Msg, State) ->
   EndTime = now(),
   StartTime = proplists:get_value(start_time, State),
   MsgSize = byte_size(Msg),
   MsgCount = proplists:get_value(msg_count, State),
   TotalMsgSize = MsgSize * MsgCount / 1000000,
   TimeDuration = timer:now_diff(EndTime, StartTime) / 1000000,
   MsgRate = MsgCount / TimeDuration,
   TransferRate = TotalMsgSize / TimeDuration,
   log(
      "==> Report:~n" ++
      "====> Remote Node: ~p~n" ++
      "====> Remote Process: ~p~n" ++
      "====> Msg count: ~p~n" ++
      "====> Msg size (each): ~p byte~n" ++
      "====> Msg size (total): ~p mbyte~n" ++
      "====> Msg rate: ~p msg/sec~n" ++
      "====> Transfer rate: ~p mbyte/sec~n" ++
      "====> Total time: ~p sec~n" ++
      "==> End~n~n",
      [
         Node, 
         Process, 
         MsgCount, 
         MsgSize,
         TotalMsgSize,
         MsgRate,
         TransferRate,
         TimeDuration
      ]
   ).

log(Text, Params) ->
   io:format(Text, Params).
