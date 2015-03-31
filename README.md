## Erlang Distributed Protocol Benchmark

This is a benchmark generator that measures the message and byte transfer rate between Erlang and Java nodes. It uses [Erlang Distributed Protocol](http://www.erlang.org/doc/apps/erts/erl_dist_protocol.html) on the wire and [Jinterface](http://www.erlang.org/doc/apps/jinterface/jinterface_users_guide.html) package for creating Java node which knows Erlang port mapper ([EPMD](http://www.erlang.org/doc/man/epmd.html)), data types and its distributed protocol.

## Benchmark

- In order to run this benchmark you need to have Erlang, Java and Gnu Make installed in your machine.
- Clone this repo into you machine
- Replace {message_count} and {message_size} with your benchmakr parameters and
- Execute `make MC={message_count} MS={message_size}` command in its root

## My Results

My machine info:
- OS: Debian 8
- RAM: 8 GB
- CPU: i5-4570 @ 3.20GHz
- Erlang: R17
- Java: 1.7

The result:
```shell
$ make MC=1000000 MS=1000
==> compiling java code
==> compiling erlang node
==> running java node
==> running erlang node
==> java node startd
==> erlang node started
==> Report:
====> Remote Node: java_node@localhost
====> Remote Process: java_process
====> Msg count: 1000000
====> Msg size (each): 1000 byte
====> Msg size (total): 1.0e3 mbyte
====> Msg rate: 47344.58654185623 msg/sec
====> Transfer rate: 47.34458654185623 mbyte/sec
====> Total time: 21.121739 sec
==> End
```

## Notes

- Messages are sent synchronously on one thread on each side
- Java Node acknowledges each Erlang Node message
- The acknowledgement message is same as the message itself
