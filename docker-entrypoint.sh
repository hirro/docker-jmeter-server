#!/bin/bash
set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

MODE="$1"
REMOTE_HOSTS="$2"

case "${MODE}" in

master)
	DIR="/results/$(date "+%Y-%m-%d/%H.%M.%S")"
	mkdir -p ${DIR}
	cd ${DIR}
	exec jmeter -n \
		-t /jmx \
		-D "java.rmi.server.hostname=${IP}" \
		-l results.jtl -e -o dashboard \
		-R ${REMOTE_HOSTS}
;;

slave)
	JMETER_LOG="jmeter-server.log" && touch $JMETER_LOG && tail -f $JMETER_LOG &
	exec jmeter-server \
		-JJVM_ID=${IP//.} \
	    -D "java.rmi.server.hostname=${IP}" \
	    -D "client.rmi.localport=${RMI_PORT}" \
	    -D "server.rmi.localport=${RMI_PORT}"
;;

esac
