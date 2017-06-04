#!/bin/bash
set -e

freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

case "$1" in

master)
	shift 1
	R="$*"
	if [ "${R}" ]; then
		R="-R ${R//\ /,}" # replace spaces with commas
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

	# run example:
	# docker run --rm --name master \
	# 	--env IP=192.168.99.100 \
	# 	--volume /home/docker/test_plan.jmx:/jmx \
	# 	--volume /home/docker/results:/results \
	# 	--publish 60000:60000 \
	# 	wscherphof/jmeter:3.2 \
	# 	master 192.168.99.103 192.168.99.104 192.168.99.105
;;

slave)
	JMETER_LOG="jmeter-server.log" && touch $JMETER_LOG && tail -f $JMETER_LOG &
	# published client port may vary 
	exec jmeter-server \
	    -D "java.rmi.server.hostname=${IP}" \
	    -D "client.rmi.localport=${CLIENT_PORT}" \
	    -D "server.rmi.localport=1099" \
		-JJVM_ID=${IP//.} # remove dots

	# run example:
	# docker run --rm --detach --name slave 
	# 	--env IP=192.168.99.103 \
	# 	--publish 1099:1099 \
	# 	wscherphof/jmeter:3.2
;;

esac
