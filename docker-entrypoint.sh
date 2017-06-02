#!/bin/bash
set -e

freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

MODE="$1"

case "${MODE}" in

master)
	shift 1
	R="$*"
	if [ "${R}" ]; then
		R="-R ${R//\ /,}" # replace spaces for commas
	fi

	cd /results
	rm -rf *
	# published server port may vary
	exec jmeter -n \
	    -D "java.rmi.server.hostname=${IP}" \
	    -D "client.rmi.localport=60000" \
	    -D "server.rmi.localport=${SERVER_PORT}" \
		-t /jmx \
		-l results.jtl -e -o dashboard \
		${R}
;;

slave)
	JMETER_LOG="jmeter-server.log" && touch $JMETER_LOG && tail -f $JMETER_LOG &
	# published client port may vary 
	exec jmeter-server \
	    -D "java.rmi.server.hostname=${IP}" \
	    -D "client.rmi.localport=${CLIENT_PORT}" \
	    -D "server.rmi.localport=1099" \
		-JJVM_ID=${IP//.}
;;

esac
