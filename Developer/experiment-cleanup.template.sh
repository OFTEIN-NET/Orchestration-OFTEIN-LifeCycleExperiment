#!/bin/bash

#
# Name 			: experiment-cleanup.gist.sh
# Description	: Script for OF@TEIN Experiment Cleanup 
#
# Created by    : TEIN_GIST@nm.gist.ac.kr
# Version       : 0.1
# Last Update	: March, 2014
#

# Configuration Parameter

REPOSITORY="103.22.221.32"
FLOWVISOR="103.22.221.52"
SDNTOOLSVR="103.22.221.53"
USERCTRL="103.22.221.140"
FLOWSPACE="192.168.2.0"
SLICE="exp-tein-2013"
countryID=""

# Main Script

echo -e "\n"
echo -e "##########################################"
echo -e "# Start Cleaning Up Experiment Resources #"
echo -e "##########################################"
echo -e "\n"

 VM_PING=`ping exp-vm-Smartx-BPlus-$countryID -c 1 | grep icmp_req`

 if [ "${VM_PING:-null}" = null ]; then
    echo -e "Host Smartx-BPlus-$countryID is not running VM for experiment !!!"
	echo -e "--------------------------------------------------------\n"
 else
    echo -e "Host Smartx-BPlus-$countryID is running VM for experiment."
	echo -e "--------------------------------------------------\n"

	EXP_PING=`ssh root@exp-vm-Smartx-BPlus-$countryID 'pgrep ping'`
	
	if [ "${EXP_PING:-null}" = null ]; then
	    echo -e "exp-vm-Smartx-BPlus-$countryID is not running experiment !!!"
		echo -e "-------------------------------------------------------------\n"
	
	else
		echo -e "exp-vm-Smartx-BPlus-$countryID is running experiment."
		echo -e "-------------------------------------------------------\n"
		echo -e "Cleaning up for Smartx-BPlus-$countryID...\n"
			
		echo -e "Stopping Ping Experiment on the Virtual Machine..."
		ssh root@exp-vm-Smartx-BPlus-$countryID "killall ping"

		echo -e "Deleting the Experiment Virtual Machine..."
		ssh tein@Smartx-BPlus-$countryID "sudo xl -f destroy exp-vm-Smartx-BPlus-$countryID"

		echo -e "Deleting the Experiment Virtual Machine Configuration Files..."
		ssh tein@Smartx-BPlus-$countryID "rm /home/tein/exp-vm-Smartx-BPlus-$countryID.cfg"

		echo -e "\nSmartx-B-$countryID is clean. \n"
	fi
	
 fi

echo -e "\n"
echo -e "#######################################"
echo -e "# Checking FlowSpace (192.168.2.0/24) #"
echo -e "#######################################"
echo -e "\n"

FVRESULT=`ssh netcs@$FLOWVISOR 'fvctl-json --passwd-file=passwd list-flowspace|grep 192.168.2.0'`

if [ -n "$FVRESULT" ]; then
        echo -e "FlowVisor have correct FlowSpace"
		echo -e "Deleting FlowSpace from FV...\n"

else
        echo -e "FlowVisor don't have FlowSpace\n"
fi
echo -e "Experiment Clean Up is  done.\n"
