#!/bin/bash

for (( ; ; ))

do
        rm sflow.json
	echo "{" >> sflow.json
	echo -e "\"ICMP\" :" >> sflow.json
	curl http://103.22.221.152:8008/activeflows/ALL/video/json >> sflow-dump.json
    	sed -i 's/\]\[/\,/g' sflow-dump.json
	cat sflow-dump.json >> sflow.json
	echo -e "}" >> sflow.json
	sleep 10
done



