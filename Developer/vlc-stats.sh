#!/bin/bash

rm vlc-bitrate.csv
rm vlc-decode.csv

declare -i x=0
awk '/input bitrate/{print $5}' vlc-stats.txt | while read line ;       
do   
    echo -n $x"," >> vlc-bitrate.csv
	echo -e "$line" >> vlc-bitrate.csv
	x=$x+1
done

declare -i y=0
awk '/video decoded/{print $5}' vlc-stats.txt | while read line ;       
do   
    echo -n $x"," >> vlc-decode.csv
	echo -e "$line" >> vlc-decode.csv
	x=$x+1
done

