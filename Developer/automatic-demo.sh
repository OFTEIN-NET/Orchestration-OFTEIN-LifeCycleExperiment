#!/bin/bash

#
# Name		: automatic-demo.sh
# Description	: Script for OF@TEIN Infrastructure Checking Resource, Executing Experiment
#				  and Displaying Result Automatically (PING, IPERF and VIDEO Experiment)
#
# Created by    : TEIN_GIST@nm.gist.ac.kr
# Version       : 0.1
# Last Update	: November, 2014
#

# CONFIGURATION PARAMETER

# FUNCTION DEFINITION

ping-demo ()

{

# Open SDN UI Window
echo -e "\n\nOpen SDN Experimenter UI"
echo -e "..........."
#sleep 3
#java -jar SDN-UI.jar &
#sleep 3

# Execute the Experiment and Measurement
echo -e "\nResource Checking Execute Experiment"
echo -e "..........."
sleep 3
./experiment-check.v6.sh
sleep 3

# Show the result from local folder images
echo -e "\nDisplaying Experiment Result"
echo -e "..........."
sleep 2
java -jar GraphShow.jar &
sleep 20

# Killall java GUI
killall java
}

iperf-demo ()

{

# Open SDN UI Window

echo -e "\n\nOpen SDN Experimenter UI"
echo -e "..........."
#sleep 3
#java -jar SDN-UI.jar &
#sleep 3

# Execute the Experiment and Measurement
echo -e "\nResource Checking Execute Experiment"
echo -e "..........."
sleep 3
./experiment-check-iperf.v5.sh
sleep 3

# Show the result from local folder images
echo -e "\nDisplaying Experiment Result"
echo -e "..........."
sleep 2
java -jar GraphShow.jar &
sleep 20

# Killall java GUI
killall java
}

video-demo ()

{
# Open SDN UI Window
echo -e "\nOpen SDN Experimenter UI"
echo -e "..........."
#sleep 3
#java -jar SDN-UI.jar &
#sleep 3

# Execute the Experiment and Measurement
echo -e "\nResource Checking Execute Experiment"
echo -e "..........."
sleep 3
./experiment-video.v6.sh
sleep 60
#killall java

# Show the result from local folder images
echo -e "\nDisplaying Experiment Result"
echo -e "..........."
sleep 2
java -jar VLCGraphShow.jar &
sleep 10

# Killall java GUI and Video
killall java
kill  $(ps aux | grep 'ssh -X' | awk '{print $2}')
VC=`ssh root@exp-vm-smartx-bplus-GIST 'pgrep vlc'`
ssh root@exp-vm-smartx-bplus-GIST kill -9 $VC
}

# MAIN PROGRAMS

case "$1" in

	ping)

		echo -e "----------------------------------------------------"
		echo -e "| AUTOMATIC PING DEMONSTRATION (RESOURCE CHECKING) |"
		echo -e "----------------------------------------------------"
		sleep 5
		ping-demo
		;;

	iperf)
		
		echo -e "---------------------------------------------------------"
		echo -e "| AUTOMATIC IPERF DEMONSTRATION (BANDWIDTH MEASUREMENT) |"
		echo -e "---------------------------------------------------------"
		sleep 5
		iperf-demo
		;;

	video)

		echo -e "---------------------------------------------------"
		echo -e "| AUTOMATIC VIDEO DEMONSTRATION (VIDEO STREAMING) |"
		echo -e "---------------------------------------------------"
		sleep 5
		video-demo
		;;

	all)

		echo -e "----------------------------------------------------"
		echo -e "| AUTOMATIC PING DEMONSTRATION (RESOURCE CHECKING) |"
		echo -e "----------------------------------------------------"
		sleep 5
		ping-demo
		echo -e "---------------------------------------------------------"
		echo -e "| AUTOMATIC IPERF DEMONSTRATION (BANDWIDTH MEASUREMENT) |"
		echo -e "---------------------------------------------------------"
		sleep 3
		iperf-demo
		echo -e "---------------------------------------------------"
		echo -e "| AUTOMATIC VIDEO DEMONSTRATION (VIDEO STREAMING) |"
		echo -e "---------------------------------------------------"
		sleep 3
		video-demo
		;;

	*)

		echo $"Usage: $0 {ping|iperf|video|all}"
		exit 1
esac
