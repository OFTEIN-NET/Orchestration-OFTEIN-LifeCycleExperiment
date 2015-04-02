#!/bin/bash

#
# Name 			: experiment-check.template.sh
# Description	: Script for OF@TEIN Infrastructure Resources Checking and Verification at specific site/country
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
SLICE="exp-tein-2013"
FLOWSPACE="192.168.2.0"
LOGDIR="log"
LOGRES="result"
LOGFILE=experiment.check.`date +%Y%m%d.%H%M%S`.log
countryID=""

# Function Definition
# ===================
#
# [1] FlowSpace Resource Checking
#

function check_flowspace {

	RESULT2=`ssh netcs@$FLOWVISOR fvctl-json --passwd-file=passwd list-flowspace|grep $FLOWSPACE`
	
	echo -e "\n"
	echo -e "--------------------------------------------------------------"
	echo -e "| Checking FlowSpace Resource for Experiment (192.168.2.0/24)|"
	echo -e "--------------------------------------------------------------"
	echo -e "\n"

	if [ -n "$RESULT2" ]; then
        	echo "FlowVisor have correct FlowSpace."
			FLOWSPACE_RESULT="OK"
	else
        	echo "FlowVisor don't have FlowSpace."
        	echo "Push FlowSpace to FV..."
		
		RESULT3=`ssh netcs@$FLOWVISOR fvctl-json --passwd-file=passwd list-flowspace|grep $FLOWSPACE`
		
		if [ -n "$RESULT3" ]; then
			echo "FlowVisor have correct FlowSpace."
			FLOWSPACE_RESULT="OK"
		else
			echo "Failed to Push FlowSpace to FV !!!"
			echo "Please contact your administrator !!!"
			FLOWSPACE_RESULT="FAILED"
		fi	
		
	fi

	
	if [ $FLOWSPACE_RESULT = "OK" ]; then
		export FLOW_RESULT="\033[32m[$FLOWSPACE_RESULT]\033[0m"
	else
		export FLOW_RESULT="\033[31m[$FLOWSPACE_RESULT]\033[0m"
	fi
	
}
#
# [2] Networking Resource Checking
#

function check_network {

echo -e "\n"
echo -e "--------------------------------------------------"
echo -e "| Start Network Resource Checking for Experiment |"
echo -e "--------------------------------------------------"
echo -e "\n"

		echo -e "Checking Tunnel for Smartx-BPlus-$countryID"
		echo -e "--------------------------------"
		
 		TUNNEL_NAME=GJ$countryID
 
		TUNNEL=`ssh netcs@$SDNTOOLSVR cat /home/netcs/AdminSDNController/Tunnel/active_tunnel.list|grep $TUNNEL_NAME`

		if [ "${TUNNEL:-null}" = null ]; then
			echo -e "Tunnel for Smartx-BPlus-$countryID is Down !!!"
			echo -e "Please contact your Administrator.\n"
			TUNNEL_RESULT="FAILED"
		else
			echo -e "Tunnel for Smartx-BPlus-$countryID is Up.\n"
			TUNNEL_RESULT="OK"

		fi

	echo -e "\nChecking done for Smartx-BPlus-$countryID.\n"
	
	if [ "$TUNNEL_RESULT" =	"OK" ]; then
		export TUNNEL_RESULT_$countryID="\033[32m[$TUNNEL_RESULT]\033[0m"
	else
		export TUNNEL_RESULT_$countryID="\033[31m[$TUNNEL_RESULT]\033[0m"
	fi
		
echo -e "Network Resources Checking Done.\n"

}
	
#
# [3] Compute Resource Checking
#

function check_compute {

	echo -e "\n"
	echo -e "--------------------------------------------------"
	echo -e "| Start Compute Resource Checking for Experiment |"
	echo -e "--------------------------------------------------"
	echo -e "\n"

		echo -e "Checking for Smartx-BPlus-$countryID"
		echo -e "----------------------------"
 
		PING=`ping Smartx-BPlus-$countryID -c 1 | grep icmp_req`

		if [ "${PING:-null}" = null ]; then
			echo "Host Smartx-BPlus-$countryID is not reachable !!!"
			COMPUTE_RESULT="FAILED"
		else
			echo "Host Smartx-BPlus-$countryID is reachable."
    
			XEN=`ssh tein@Smartx-BPlus-$countryID 'sudo xl list | grep Domain-0'`
    
			if [ "${XEN:-null}" = null ]; then
				echo "XEN Domain-0 is not running !!!"
				echo "Please contact the administrator !!!"
				COMPUTE_RESULT="FAILED"	
			else
				echo "XEN Domain-0 is running."
			fi

			VM=`ssh tein@Smartx-BPlus-$countryID 'sudo xl list | grep exp-vm'`

			if [ "${VM:-null}" = null ]; then
				echo "Experiment Virtual Machine is not started yet !!!"
				echo "Starting Experiment Virtual Machine..."
				ssh tein@Smartx-BPlus-$countryID "scp netcs@$SDNTOOLSVR:Exp-LifeCycle-Mgmt/exp-vm-Smartx-BPlus-$countryID.cfg ." >> $LOGDIR/$LOGFILE 2>&1
				ssh tein@Smartx-BPlus-$countryID "sudo xl -f create /home/tein/exp-vm-Smartx-BPlus-$countryID.cfg" >> $LOGDIR/$LOGFILE 2>&1
								
				VM2=`ssh tein@Smartx-BPlus-$countryID 'sudo xl list | grep exp-vm'`
				
				if [ "${VM2:-null}" = null ]; then
					echo "Experiment Virtual Machine is failed to start !!!"
					COMPUTE_RESULT="FAILED"
				else
					echo "Experiment Virtual Machine is started."
				fi
				
			else
				echo "Experiment Virtual Machine is already started."
			fi
			
			sleep 8
						
			VM_PING=`ping exp-vm-Smartx-BPlus-$countryID -c 1 | grep icmp_req`

			if [ "${VM_PING:-null}" = null ]; then	
				echo "Experiment Virtual Machine is not reachable !!!"
				COMPUTE_RESULT="FAILED"
			else
				echo "Experiment Virtual Machine is reachable."
				COMPUTE_RESULT="OK"	
			fi
    	
		fi

	echo -e "\nChecking done for Smartx-BPlus-$countryID.\n"
	
	if [ "$COMPUTE_RESULT" =	"OK" ]; then
		export COMPUTE_RESULT_$countryID="\033[32m[$COMPUTE_RESULT]\033[0m"
	else
		export COMPUTE_RESULT_$countryID="\033[31m[$COMPUTE_RESULT]\033[0m"
	fi
	
echo -e "Compute Resource Checking for Experiment is done...\n"

}

#
# [3] Execute Experiment Function
#

function experiment_start {

echo -e "-----------------------------"
echo -e "| Executing PING Experiment |"
echo -e "-----------------------------"

echo -e "\n"
echo -e "Start PING Application for exp-vm-Smartx-BPlus-$countryID"
echo -e "-----------------------------------------------------------"

VM_PING2=`ping exp-vm-Smartx-BPlus-$countryID -c 1 | grep icmp_req`

	if [ "${VM_PING2:-null}" = null ]; then	
		echo "Experiment Virtual Machine is not reachable !!!"
		EXP_RESULT="FAILED"		
	else
		echo "Experiment Virtual Machine is reachable."
		echo "Start the PING application in Experiment Virtual Machine..."
		
		ssh root@exp-vm-Smartx-BPlus-$countryID "nohup ping 192.168.2.1 > /dev/null &"
		sleep 2
		
		EXP_PING2=`ssh root@exp-vm-Smartx-BPlus-$countryID 'pgrep ping'`
	
		if [ "${EXP_PING2:-null}" = null ]; then	
			echo -e "Experiment for exp-vm-Smartx-BPlus-$countryID is not started yet !!!\n"
			EXP_RESULT="FAILED"
		else
			echo -e "Experiment for exp-vm-Smartx-BPlus-$countryID is started.\n"
			EXP_RESULT="OK"
		fi
		
	fi

if [ "$EXP_RESULT" =	"OK" ]; then
	export EXP_RESULT_$countryID="\033[32m[$EXP_RESULT]\033[0m"
else
	export EXP_RESULT_$countryID="\033[31m[$EXP_RESULT]\033[0m"
fi
	
}

#
# Main Script
#

echo -e "\n"
echo -e "####################################################"
echo -e "# Checking Infrastructure Resources for Experiment #"
echo -e "####################################################"

touch $LOGDIR/$LOGFILE

check_flowspace
sleep 2
check_network
sleep 2
check_compute
sleep 3
experiment_start

COMPUTE_RESULT2=COMPUTE_RESULT_$countryID
TUNNEL_RESULT2=TUNNEL_RESULT_$countryID
EXP_RESULT2=EXP_RESULT_$countryID

echo -e "Checking Infrastructure Resource for Experiment is Done.\n"
echo -e "###########################"
echo -e "# Checking Result Summary #"
echo -e "###########################\n"
echo -e "FlowSpace Resource Status			: $FLOW_RESULT\n"
echo -e "Compute Resource Status for Smartx-BPlus-$countryID  	: ${!COMPUTE_RESULT2}"
echo -e "Network Resource Status for Smartx-BPlus-$countryID  	: ${!TUNNEL_RESULT2}"
echo -e "Experiment Execution for Smartx-BPlus-$countryID	: ${!EXP_RESULT2}"
echo -e "\n"
echo -e "Please check the \"$LOGFILE\" for detail result."
echo -e "\n"
