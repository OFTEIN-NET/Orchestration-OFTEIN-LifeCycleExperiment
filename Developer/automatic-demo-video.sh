#!/bin/bash

#
# Name 			: experiment-all-video.sh
# Description	: Script for OF@TEIN Infrastructure Checking Resource, Executing Experiment
#				  and Displaying Result
#
# Created by    : TEIN_GIST@nm.gist.ac.kr
# Version       : 0.1
# Last Update	: November, 2014
#

# Configuration Parameter



# Execution

# Open SDN UI Window

echo -e "\nOpen SDN Experimenter UI"
echo -e "..........."
sleep 3
#java -jar SDN-UI.jar &
#sleep 3

# Execute the Experiment and Measurement
echo -e "\nResource Checking Execute Experiment"
echo -e "..........."
sleep 3
#./experiment-check.v6.sh
#./experiment-check-iperf.v5.sh
./experiment-video.v6.sh
sleep 60
#killall java

# Show the result from local folder images
echo -e "\nDisplaying Experiment Result"
echo -e "..........."
sleep 2
#java -jar GraphShow.jar &
java -jar VLCGraphShow.jar &
sleep 10

# Killall java GUI and Video
killall java
kill  $(ps aux | grep 'ssh -X' | awk '{print $2}')
VC=`ssh root@exp-vm-smartx-bplus-GIST 'pgrep vlc'`
ssh root@exp-vm-smartx-bplus-GIST kill -9 $VC
