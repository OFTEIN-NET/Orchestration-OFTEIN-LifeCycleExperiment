#!/bin/bash

#
# Name 			: experiment-cleanup.sh
# Description	: Script for OF@TEIN Experiment Cleanup 
#
# Created by    : TEIN_GIST@nm.gist.ac.kr
# Version       : 0.5
# Last Update	: March, 2014
#

# Configuration Parameter

FLOWVISOR="103.22.221.52"
USERCTRL="103.22.221.140"
SLICE="exp-tein-2013"
FLOWSPACE="192.168.2.0"
BP_SITES="TEST GIST" # separated by spaces

# Main Script

echo -e "\n"
echo -e "##########################################"
echo -e "# Start Cleaning Up Experiment Resources #"
echo -e "##########################################"
echo -e "\n"


for countryID in $BP_SITES
do

 VM_PING=`ssh root@Smartx-BPlus-$countryID 'xl list | grep exp-vm-Smartx-BPlus'`

 if [ "${VM_PING:-null}" = null ]; then
    echo -e "Host Smartx-BPlus-$countryID is not running VM for experiment !!!"
	echo -e "--------------------------------------------------------\n"
 else
    echo -e "Host Smartx-BPlus-$countryID is running VM for experiment."
	echo -e "--------------------------------------------------\n"

	echo -e "Cleaning up for Smartx-BPlus-$countryID...\n"
			
	echo -e "Deleting the Experiment Virtual Machine..."
	ssh root@Smartx-BPlus-$countryID "xl -f destroy exp-vm-Smartx-BPlus-$countryID"

	echo -e "Deleting the Experiment Virtual Machine Configuration Files..."
	ssh root@Smartx-BPlus-$countryID "rm /home/tein/exp-vm-Smartx-BPlus-$countryID.cfg"

	echo -e "\nSmartx-B-$countryID is clean. \n"

	
 fi

done

echo -e "\n"
echo -e "#######################################"
echo -e "# Checking FlowSpace (192.168.2.0/24) #"
echo -e "#######################################"
echo -e "\n"

RESULT2=`ssh netcs@$FLOWVISOR fvctl-json --passwd-file=passwd list-flowspace|grep $FLOWSPACE`

if [ -n "$RESULT2" ]; then
        echo -e "FlowVisor have correct FlowSpace"
		echo -e "Deleting FlowSpace from FV...\n"
        ssh netcs@$USERCTRL "~/tein2013/experiment/close_exp.sh ~/tein2013/experiment/$SLICE"
        ssh netcs@$USERCTRL "~/tein2013/experiment/close_flowspaces.sh ~/tein2013/experiment/$SLICE"
		ssh netcs@$USERCTRL "kill -9 $(ps -aux | grep nox | awk '{print $2}')"
else
        echo -e "FlowVisor don't have FlowSpace\n"
fi
echo -e "Experiment Clean Up is  done.\n"

