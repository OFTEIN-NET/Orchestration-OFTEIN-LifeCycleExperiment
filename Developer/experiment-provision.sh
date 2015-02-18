#!/bin/bash

#
# Name 			: experiment-check.sh
# Description	: Script for OF@TEIN Infrastructure Resources Checking and Verification
#
# Created by    : TEIN_GIST@nm.gist.ac.kr
# Version       : 0.5
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
BP_SITES="GIST MYREN PH MY" # separated by spaces

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
        	ssh netcs@$USERCTRL "~/tein2013/experiment/prepare_exp.sh ~/tein2013/experiment/$SLICE" >> $LOGDIR/$LOGFILE 2>&1
        	ssh netcs@$USERCTRL "~/tein2013/experiment/prepare_flowspaces.sh ~/tein2013/experiment/$SLICE" >> $LOGDIR/$LOGFILE 2>&1
		
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

for countryID in $BP_SITES MY2 PK VT
	do
		echo -e "Checking Tunnel for smartx-B-$countryID"
		echo -e "--------------------------------"
		
 		TUNNEL_NAME=GJ"$countryID"
 
		TUNNEL=`ssh netcs@$SDNTOOLSVR "cat ~/AdminSDNController/Tunnel/tunnel.list|grep $TUNNEL_NAME"`

		if [ "${TUNNEL:-null}" = null ]; then
			echo -e "Tunnel for smartx-B-$countryID is Down !!!"
			echo -e "Please contact your Administrator.\n"
			TUNNEL_RESULT="FAILED"
		else
			echo -e "Tunnel for smartx-B-$countryID is Up.\n"
			TUNNEL_RESULT="OK"

		fi

	echo -e "\nChecking done for smartx-B-$countryID.\n"
	
	if [ "$TUNNEL_RESULT" =	"OK" ]; then
		export TUNNEL_RESULT_$countryID="\033[32m[$TUNNEL_RESULT]\033[0m"
	else
		export TUNNEL_RESULT_$countryID="\033[31m[$TUNNEL_RESULT]\033[0m"
	fi
		
	done

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

	for countryID in $BP_SITES
	do
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
				echo "XEN Domain-0 (Hypervisor) is problem !!!"
				echo "Please contact the administrator !!!"
				COMPUTE_RESULT="FAILED"	
			else
				echo "XEN Domain-0 (Hypervisor) is running."
			fi

			VM=`ssh tein@Smartx-BPlus-$countryID 'sudo xl list | grep exp-vm-Smartx-BPlus'`

			if [ "${VM:-null}" = null ]; then
				echo "Experiment Virtual Machine is not started yet !!!"
				echo "Starting Experiment Virtual Machine..."
				
				knife bootstrap SmartX-BPlus-$countryID -x root -r 'recipe[smartx-bp-function::basic-config]'
				
				#ssh tein@Smartx-BPlus-$countryID "scp netcs@$SDNTOOLSVR:Exp-LifeCycle-Mgmt/exp-vm-Smartx-BPlus-$countryID.cfg ." >> $LOGDIR/$LOGFILE 2>&1
				#ssh tein@Smartx-BPlus-$countryID "sudo xl -f create /home/tein/exp-vm-Smartx-BPlus-$countryID.cfg" >> $LOGDIR/$LOGFILE 2>&1
			
				sleep 4 
										
				VM2=`ssh tein@Smartx-BPlus-$countryID 'sudo xl list | grep exp-vm-Smartx-BPlus'`
				
				if [ "${VM2:-null}" = null ]; then
					echo "Experiment Virtual Machine is failed to start !!!"
					COMPUTE_RESULT="FAILED"
				else
					echo "Experiment Virtual Machine is started."
				fi
				
			else
				echo "Experiment Virtual Machine is already started."
			fi
			
			sleep 6 
						
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
	
	done
	
echo -e "Compute Resource Checking for Experiment is done...\n"

}

#
# [3] Execute Experiment Function (Continuous PING)
#

function experiment_start {

echo -e "-----------------------------"
echo -e "| Executing PING Experiment |"
echo -e "-----------------------------"

for countryID in $BP_SITES
do
	
echo -e "\n"
echo -e "Start PING Application for ubuntu-experiment-vm-Smartx-B-$countryID"
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
	
done

}


#
# [4] Execute Experiment Function (PING 5 times)
#

function new_experiment_start {

echo -e "-----------------------------"
echo -e "| Executing PING Experiment |"
echo -e "-----------------------------"

rm $LOGRES/ping-test.txt

   echo "               PING Experiment Result ">> $LOGRES/ping-test.txt
   echo "-------------------------------------------------------------">> $LOGRES/ping-test.txt
   echo "|    Exp VMs	|    Result     |   Min/Avg/Max/MDev(msec)   |">> $LOGRES/ping-test.txt
   echo "-------------------------------------------------------------">> $LOGRES/ping-test.txt

for countryID in $B_SITES
do
	
echo -e "\n"
echo -e "Start PING Application for ubuntu-experiment-vm-Smartx-B-$countryID"
echo -e "----------------------------------------------------"

VM_PING2=`ping ubuntu-experiment-vm-Smartx-B-$countryID -c 1 | grep icmp_req`

	if [ "${VM_PING2:-null}" = null ]; then	
		echo "Experiment Virtual Machine is not reachable !!!"
		echo "|    $countryID-GIST	|    FAILED     |           -/-/-/-          |" >> $LOGRES/ping-test.txt
		EXP_RESULT="FAILED"		
	else
		echo "Experiment Virtual Machine is reachable."
		echo "Start the PING application in Experiment Virtual Machine..."
			
		EXP_PING=$(ssh root@ubuntu-experiment-vm-Smartx-B-$countryID 'ping -c 5 192.168.2.1 | grep icmp_req')
		EXP_RESULT="OK"
		
		if [ "${EXP_PING:-null}" = null ]; then
			echo "PING Result $countryID is FAILED !!!"
			echo "|    $countryID-GIST	|    FAILED     |           -/-/-/-          |" >> $LOGRES/ping-test.txt

		else
			echo "PING Result $countryID is OK"
			TIME=$(ping -c 10 103.22.221.53 | grep rtt | awk '{print $4}')
			echo "|    $countryID-GIST	|      OK       |  $TIME   |" >> $LOGRES/ping-test.txt
		fi
		
	fi

if [ "$EXP_RESULT" =	"OK" ]; then
	export EXP_RESULT_$countryID="\033[32m[$EXP_RESULT]\033[0m"
else
	export EXP_RESULT_$countryID="\033[31m[$EXP_RESULT]\033[0m"
fi
	
done
   
   
   
for countryID in $BP_SITES
do
	
echo -e "\n"
echo -e "Start PING Application for exp-vm-Smartx-BPlus-$countryID"
echo -e "----------------------------------------------------"

VM_PING2=`ping exp-vm-Smartx-BPlus-$countryID -c 1 | grep icmp_req`

	if [ "${VM_PING2:-null}" = null ]; then	
		echo "Experiment Virtual Machine is not reachable !!!"
		echo "|    $countryID-GIST	|    FAILED     |           -/-/-/-          |" >> $LOGRES/ping-test.txt
		EXP_RESULT="FAILED"		
	else
		echo "Experiment Virtual Machine is reachable."
		echo "Start the PING application in Experiment Virtual Machine..."
			
		EXP_PING=$(ssh root@exp-vm-Smartx-BPlus-$countryID 'ping -c 5 192.168.2.1 | grep icmp_req')
		EXP_RESULT="OK"
		
		if [ "${EXP_PING:-null}" = null ]; then
			echo "PING Result $countryID is FAILED !!!"
			echo "|    $countryID-GIST	|    FAILED     |           -/-/-/-          |" >> $LOGRES/ping-test.txt

		else
			echo "PING Result $countryID is OK"
			TIME=$(ping -c 10 103.22.221.53 | grep rtt | awk '{print $4}')
			echo "|    $countryID-GIST	|      OK       |  $TIME   |" >> $LOGRES/ping-test.txt
		fi
		
	fi

if [ "$EXP_RESULT" =	"OK" ]; then
	export EXP_RESULT_$countryID="\033[32m[$EXP_RESULT]\033[0m"
else
	export EXP_RESULT_$countryID="\033[31m[$EXP_RESULT]\033[0m"
fi
	
done

   echo "-------------------------------------------------------------">> $LOGRES/ping-test.txt

cd $LOGRES
enscript -B -f Courier-Bold14 ping-test.txt -o - | ps2pdf - graph.pdf
convert -density 300 -trim graph.pdf -quality 100 graph-temp.jpg
convert -resize 600x400 graph-temp.jpg graph.jpg
#scp graph.jpg root@NML:images/
cp graph.jpg ../images/
cd ..

}

function clean_nox_log {

LOG=`ssh netcs@$USERCTRL "ls -la ~/logs/exp-exp-tein-2013/nox.netcs@103.22.221.140.log"`

if [ -n "$LOG" ]; then
        echo "NOX Log File is exists !!! " 
		echo "Deleting NOX Log file to save the disk..."
		ssh netcs@$USERCTRL "rm ~/logs/exp-exp-tein-2013/nox.netcs@103.22.221.140.log" >> $LOGDIR/$LOGFILE 2>&1
		echo "NOX Log File is deleted."
else
        echo "NOX Log File is not exists."
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

for countryID in GIST ID MY TH PH VN VT MYREN MY2 PKS
do

	export COMPUTE_RESULT_$countryID="[N/A]"
	export TUNNEL_RESULT_$countryID="[N/A]"
	export EXP_RESULT_$countryID="[N/A]"
	
done

check_flowspace
sleep 2
check_network
sleep 2
check_compute
sleep 3
experiment_start
new_experiment_start
sleep 2
#clean_nox_log

echo -e "Checking Infrastructure Resource for Experiment is Done.\n"
echo -e "###########################"
echo -e "# Checking Result Summary #"
echo -e "###########################\n"
echo -e "FlowSpace Resource Status				: $FLOW_RESULT\n"
echo -e "Compute Resource Status for Smartx-BPlus-GIST 		: $COMPUTE_RESULT_GIST"
echo -e "Compute Resource Status for Smartx-BPlus-ID 		: $COMPUTE_RESULT_ID"
echo -e "Compute Resource Status for Smartx-BPlus-MY 		: $COMPUTE_RESULT_MY"
echo -e "Compute Resource Status for Smartx-B-TH 		: $COMPUTE_RESULT_TH"
echo -e "Compute Resource Status for Smartx-B-PH 		: $COMPUTE_RESULT_PH"
echo -e "Compute Resource Status for Smartx-B-VN 		: $COMPUTE_RESULT_VN"
echo -e "Compute Resource Status for Smartx-BPlus-MYREN  	: $COMPUTE_RESULT_MYREN"
echo -e "Compute Resource Status for Smartx-BPlus-PKS 		: $COMPUTE_RESULT_PKS\n"
echo -e "Network Resource Status for Smartx-BPlus-GIST 		: $TUNNEL_RESULT_GIST"
echo -e "Network Resource Status for Smartx-BPlus-ID 		: $TUNNEL_RESULT_ID"
echo -e "Network Resource Status for Smartx-BPlus-MY 		: $TUNNEL_RESULT_MY"
echo -e "Network Resource Status for Smartx-BPlus-TH 		: $TUNNEL_RESULT_TH"
echo -e "Network Resource Status for Smartx-BPlus-PH 		: $TUNNEL_RESULT_PH"
echo -e "Network Resource Status for Smartx-BPlus-VN 		: $TUNNEL_RESULT_VT"
echo -e "Network Resource Status for Smartx-BPlus-MYREN  	: $TUNNEL_RESULT_MY2"
echo -e "Network Resource Status for Smartx-BPlus-PKS  		: $TUNNEL_RESULT_PK\n"
echo -e "Experiment Execution for exp-vm-Smartx-BPlus-GIST	: $EXP_RESULT_GIST"
echo -e "Experiment Execution for exp-vm-Smartx-BPlus-ID		: $EXP_RESULT_ID"
echo -e "Experiment Execution for exp-vm-Smartx-BPlus-MY		: $EXP_RESULT_MY"
echo -e "Experiment Execution for exp-vm-Smartx-B-TH		: $EXP_RESULT_TH"
echo -e "Experiment Execution for exp-vm-Smartx-B-PH		: $EXP_RESULT_PH"
echo -e "Experiment Execution for exp-vm-Smartx-B-VN		: $EXP_RESULT_VN"
echo -e "Experiment Execution for exp-vm-Smartx-BPlus-MYREN	: $EXP_RESULT_MYREN"
echo -e "Experiment Execution for exp-vm-Smartx-BPlus-PKS	: $EXP_RESULT_PKS"
echo -e "\n"
echo -e "Please check the \"$LOGFILE\" for detail result."
echo -e "\n"
