#!/bin/bash

#
# Name 			: experiment-all.sh
# Description	: Script for OF@TEIN Infrastructure Checking Resource, Executing Experiment
#				  and Displaying Result
#
# Created by    : TEIN_GIST@nm.gist.ac.kr
# Version       : 0.1
# Last Update	: November, 2014
#

# Configuration Parameter

# Execution

echo -e "-------------------------------------------------"
echo -e "| AUTOMATIC PING EXPERIMENT (RESOURCE CHECKING) |"
echo -e "-------------------------------------------------"
sleep 5

./automatic-experiment-ping.sh

echo -e "------------------------------------------------------"
echo -e "| AUTOMATIC IPERF EXPERIMENT (BANDWIDTH MEASUREMENT) |"
echo -e "------------------------------------------------------"
sleep 5
./automatic-experiment-iperf.sh

echo -e "------------------------------------------------"
echo -e "| AUTOMATIC VIDEO EXPERIMENT (VIDEO STREAMING) |"
echo -e "------------------------------------------------"
sleep 5

./automatic-experiment-video.sh
