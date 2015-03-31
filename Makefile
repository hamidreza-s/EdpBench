PWD := $(shell pwd)
JAVA_NODE := "java_node"
JAVA_PROCESS := "java_process"
JAVA_PID_PATH := "/tmp/java_edp.pid"
REMOTE_NODE := "java_node@localhost"
REMOTE_PROCESS := "java_process"
ERLANG_MODULE := "erlang_node"
ERLANG_NODE := "erlang_node"
JAVA_CLASS := "JavaNode"

ifdef MS
   MSG_SIZE := $(MS)
else
   MSG_SIZE := 1000
endif

ifdef MC
   MSG_COUNT := $(MC)
else
   MSG_COUNT := 1000
endif

.PHONY: run compile java_compile erlang_compile

run: java_compile erlang_compile
	@echo "==> running java node"
	@java \
		-cp "$(PWD)/java/:$(PWD)/java/lib/OtpErlang.jar" \
		JavaNode $(JAVA_NODE) $(JAVA_PROCESS) & echo $$! > $(JAVA_PID_PATH)
	@echo "==> running erlang node"
	@erl \
		-sname $(ERLANG_NODE) \
		-pa $(PWD)/erlang \
		-run $(ERLANG_MODULE) start \
		-run init stop \
		-noshell
	@kill `cat $(JAVA_PID_PATH)`

java_compile:
	@echo "==> compiling java code"
	@exec javac \
		-cp "$(PWD)/java:$(PWD)/java/lib/OtpErlang.jar" $(PWD)/java/$(JAVA_CLASS).java

erlang_compile:
	@echo "==> compiling erlang node"
	@exec erlc \
		-DREMOTE_NODE=$(REMOTE_NODE) -DREMOTE_PROCESS=$(REMOTE_PROCESS) \
		-DMSG_SIZE=$(MSG_SIZE) -DMSG_COUNT=$(MSG_COUNT) \
		-o "$(PWD)/erlang/" $(PWD)/erlang/erlang_node.erl
