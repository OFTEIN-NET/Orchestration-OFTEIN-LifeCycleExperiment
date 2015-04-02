#!/bin/bash

#
# Name 		: experiment-check-iperf.v3.sh
# Description	: Script for OF@TEIN Infrastructure Resources Checking and Verification
#
# Created by    : TEIN_GIST@nm.gist.ac.kr
# Version       : 0.5
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
B_SITES=""
#BP_SITES="GIST ID" # separated by spaces

BP_SITES="GIST MYREN" # separated by spaces

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

for countryID in $B_SITES $BP_SITES MY2
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

	for countryID in $B_SITES
	do
		echo -e "Checking for Smartx-B-$countryID"
		echo -e "------------------------"
 
		PING=`ping Smartx-B-$countryID -c 1 | grep icmp_req`

		if [ "${PING:-null}" = null ]; then
			echo "Host Smartx-B-$countryID is not reachable !!!"
			COMPUTE_RESULT="FAILED"
		else
			echo "Host Smartx-B-$countryID is reachable."
    
			XEN=`ssh root@Smartx-B-$countryID 'xm list | grep Domain-0'`
    
			if [ "${XEN:-null}" = null ]; then
				echo "XEN Domain-0 is not running !!!"
				echo "Please contact the administrator !!!"
				COMPUTE_RESULT="FAILED"	
			else
				echo "XEN Domain-0 is running."
			fi

			VM=`ssh root@Smartx-B-$countryID 'xm list | grep experiment-vm'`

			if [ "${VM:-null}" = null ]; then
				echo "Experiment Virtual Machine is not started yet !!!"
				echo "Starting Experiment Virtual Machine..."
				ssh root@Smartx-B-$countryID "scp netcs@$SDNTOOLSVR:Exp-LifeCycle-Mgmt/ubuntu-experiment-vm-Smartx-B-$countryID.cfg ." >> $LOGDIR/$LOGFILE 2>&1
				ssh root@Smartx-B-$countryID "xm create /root/ubuntu-experiment-vm-Smartx-B-$countryID.cfg" >> $LOGDIR/$LOGFILE 2>&1
				sleep 5
				
				VM2=`ssh root@Smartx-B-$countryID 'xm list | grep experiment-vm'`
				
				if [ "${VM2:-null}" = null ]; then
					echo "Experiment Virtual Machine is failed to start !!!"
					COMPUTE_RESULT="FAILED"
				else
					echo "Experiment Virtual Machine is started."
				fi
				
			else
				echo "Experiment Virtual Machine is already started."
			fi
			
			VM_PING=`ping ubuntu-experiment-vm-Smartx-B-$countryID -c 1 | grep icmp_req`

			if [ "${VM_PING:-null}" = null ]; then	
				echo "Experiment Virtual Machine is not reachable !!!"
				COMPUTE_RESULT="FAILED"
			else
				echo "Experiment Virtual Machine is reachable."
				COMPUTE_RESULT="OK"	
			fi
    	
		fi

	echo -e "\nChecking done for Smartx-B-$countryID.\n"
	
	if [ "$COMPUTE_RESULT" =	"OK" ]; then
		export COMPUTE_RESULT_$countryID="\033[32m[$COMPUTE_RESULT]\033[0m"
	else
		export COMPUTE_RESULT_$countryID="\033[31m[$COMPUTE_RESULT]\033[0m"
	fi
	
	done

for countryID in $BP_SITES
        do
                echo -e "Checking for Smartx-BPlus-$countryID"
                echo -e "----------------------------"

                PING=`ping Smartx-BPlus-$countryID -c 3 | grep icmp_req`

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

                        VM=`ssh tein@Smartx-BPlus-$countryID 'sudo xl list | grep exp-vm-Smartx-BPlus'`

                        if [ "${VM:-null}" = null ]; then
                                echo "Experiment Virtual Machine is not started yet !!!"
                                echo "Starting Experiment Virtual Machine..."
                                ssh tein@Smartx-BPlus-$countryID "scp netcs@$SDNTOOLSVR:Exp-LifeCycle-Mgmt/exp-vm-SmartX-BPlus-$countryID.cfg ." >> $LOGDIR/$LOGFILE 2>&1
                                ssh tein@Smartx-BPlus-$countryID "sudo xl -f create /home/tein/exp-vm-SmartX-BPlus-$countryID.cfg" >> $LOGDIR/$LOGFILE 2>&1

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

                        sleep 4

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

        if [ "$COMPUTE_RESULT" =        "OK" ]; then
                export COMPUTE_RESULT_$countryID="\033[32m[$COMPUTE_RESULT]\033[0m"
        else
                export COMPUTE_RESULT_$countryID="\033[31m[$COMPUTE_RESULT]\033[0m"
        fi

        done

	
echo -e "Compute Resource Checking for Experiment is done...\n"

}

#
# [3] Execute Experiment Function
#

function experiment_start {

echo -e "-----------------------------"
echo -e "| Executing PING Experiment |"
echo -e "-----------------------------"

for countryID in $B_SITES $BP_SITES
do
	
echo -e "\n"
echo -e "Start PING Application for ubuntu-experiment-vm-Smartx-B-$countryID"
echo -e "-----------------------------------------------------------"

VM_PING=`ping ubuntu-experiment-vm-Smartx-B-$countryID -c 1 | grep icmp_req`

	if [ "${VM_PING:-null}" = null ]; then	
		echo "Experiment Virtual Machine is not reachable !!!"
		EXP_RESULT="FAILED"		
	else
		echo "Experiment Virtual Machine is reachable."
		echo "Start the PING application in Experiment Virtual Machine..."
		
		ssh root@ubuntu-experiment-vm-Smartx-B-$countryID "nohup ping 192.168.2.1 > /dev/null &"
		sleep 2
		
		EXP_PING=`ssh root@ubuntu-experiment-vm-Smartx-B-$countryID 'pgrep ping'`
	
		if [ "${EXP_PING:-null}" = null ]; then	
			echo -e "Experiment for ubuntu-experiment-vm-Smartx-B-$countryID is not running !!!\n"
			EXP_RESULT="FAILED"
		else
			echo -e "Experiment for ubuntu-experiment-vm-Smartx-B-$countryID is running.\n"
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
#[4] Execute Iperf Experiment
#


function iperf_experiment {

TIME=5
PROC=2
COUNT=1
j=0

#SITES="$B_SITES $BP_SITES"

echo -e "\n"
echo -e "------------------------------"
echo -e "| Executing iperf Experiment |"
echo -e "------------------------------"

for countryID in $BP_SITES
do

	SRVNAME=$countryID

	TEMP=$( cat /etc/hosts | grep vm-Smart | grep $SRVNAME | awk '{print $2}')
	SRVSITE=$(echo $TEMP | awk '{print $1}')
	
	echo -e "\n"
	echo -e "Start Iperf Server Application at VM on $SRVNAME SITE"
	echo -e "-----------------------------------------------------------\n"


	echo "SRVSITE=$SRVSITE"


	
	#Check that Server is alive	
	SRV_PING=`ping $SRVSITE -c 1 | grep icmp_req`

	if [ "${SRV_PING:-null}" = null ]; then
		echo "VM on $SRVNAME is not reachable"
		EXP_RESULT="FAILED"
		continue
	fi
	
	#Execute Iperf Server UDP Mode on Server
	ssh root@$SRVSITE 'iperf -s -D'&
	sleep 5
	echo -e "\n"
		
	#Get Iperf Server IP Address
	SRVIP=$(ssh root@$SRVSITE 'ifconfig'| grep "192.168" | awk '{print $2}' |sed "s/[^0-9|.]//g;")


	echo "SRVIP=$SRVIP"


	i=1
	while [ $i -ne 0 ];do		
		#Get one site name from SITES lists and compare it with Server name
		CLNAME=`echo $BP_SITES | awk -v ii="$i" '{print $ii}'`
		
		if [ "${CLNAME:-null}" == null ]; then
			break	
		else 
			if [ $CLNAME == $SRVNAME ]; then
				let i=i+1
				continue
			fi
		fi

		#Get Client Full Name from /etc/hosts file (e.g ubuntu-experiment-vm-SmartxB-XX)
		#TEMP=`echo $BP_SITES | grep $CLNAME`
		
#		if [ "${TEMP:-null}" != null ]; then
#			TEMP=$(cat /etc/hosts | grep vm-Smartx-B- | grep $CLNAME | awk '{print $2}')
#		else
#			TEMP=$(cat /etc/hosts | grep exp-vm-SmartX-BPlus | grep $CLNAME | awk '{print $2}')
#		fi

		#CLSITE=$(echo $TEMP | awk '{print $1}')
		CLSITE=exp-vm-Smartx-BPlus-$CLNAME


		echo "CLSITE=$CLSITE"



		SRCTODEST=${CLNAME}to${SRVNAME}

		#Check whether Client Host is reachable and Check connection between Client and Server
		CL_PING=`ping $CLSITE -c 1 | grep icmp_req`
		if [ "${CL_PING:-null}" == null ]; then
			echo "VM on $CLNAME SITE is not reachable"
			echo -e "Skip $SRCTODEST TEST\n"
			EXP_RESULT="FAILED"
			let i=i+1
			continue
		fi

		CL_PING2=`ssh root@$CLSITE "ping $SRVIP -c 1" | grep icmp_req`
		

		echo "CLPING2=$CLPING"



		if [ "${CL_PING2:-null}" == null ]; then
			echo "There is no Connection between VMs on $SRVNAME and $CLNAME Site"
			echo -e "Skip $SRCTODEST Test\n"
			EXP_RESULT="FAILED"
			let i=i+1
			continue
		fi

		#Execute Iperf Client on Client Site
		#Iperf Experiment repeats 5 times
		echo -e "\nStart iperf client on $CLNAME Site\n"
	
		echo -e "Server Site : $SRVSITE"
		echo -e "Client Site : $CLSITE"
		
		if [ -f "${LOGRES}/$SRCTODEST" ]; then
			rm ./${LOGRES}/${SRCTODEST}
		fi

		let COUNT=1
		while [ $COUNT -lt 6 ];do
			echo "========================== COUNT = $COUNT ================================" >> $LOGRES/$SRCTODEST

			echo "Experiment# = $COUNT"
			
			ssh root@$CLSITE "iperf -c '$SRVIP' -t $TIME -w 50k -P $PROC -m" >> $LOGRES/$SRCTODEST
	
			let COUNT=COUNT+1
			
		done

		let i=i+1

		#Check whether Experiments were done successfully or not
		#through procedure which count # of words and lines in result file.
		awk -f $LOGRES/MTU_BW.awk  $LOGRES/$SRCTODEST > $LOGRES/$SRCTODEST.dat
		TEMPL=`cat $LOGRES/$SRCTODEST.dat | wc -l`
		TEMPW=`cat $LOGRES/$SRCTODEST.dat | wc -w`
		let COUNT=COUNT-1

		echo " $TEMPL -ne $COUNT -a $TEMPW -ne $(($COUNT*2)) "
	
		if [ $TEMPL -ne $COUNT -a $TEMPW -ne $(($COUNT*2)) ]; then
			echo "Experiment Failed"
			rm $LOGRES/$SRCTODEST $LOGRES/$SRCTODEST.dat
			EXP_RESULT="FAILED"
			continue;
		else
			RES_LIST[$j]=$SRCTODEST
			let j=j+1
		fi

		
		EXP_RESULT="OK"
		
	done
	
	echo "Terminate iperf Server on the $SRVNAME Site"
	ssh root@$SRVSITE 'killall -r -s KILL iperf'
	
	
	if [ "$EXP_RESULT" =	"OK" ]; then
		export EXP_RESULT_$countryID="\033[32m[$EXP_RESULT]\033[0m"
	else
		export EXP_RESULT_$countryID="\033[31m[$EXP_RESULT]\033[0m"
	fi	

done

i=0
let j=j-1

if [ $j -ne -1 ]; then
	cd $LOGRES/
		
	echo "set term postscript eps">IPERF_RES.dos
	echo "set output 'IPERF_RES.eps'">>IPERF_RES.dos
	echo 'set xlabel "COUNT"'>>IPERF_RES.dos
	echo 'set ylabel "Mbps"'>>IPERF_RES.dos
	echo "set samples 500">>IPERF_RES.dos
	echo 'set style line 81 lt rgb "#808080"'>>IPERF_RES.dos
	echo "set style line 81 lt 0">>IPERF_RES.dos
	echo "set grid ytics linestyle 81">>IPERF_RES.dos
	echo "set xtics auto">>IPERF_RES.dos
	echo "set xtics nomirror">>IPERF_RES.dos
	echo "set ytics auto">>IPERF_RES.dos
	echo "set ytics nomirror">>IPERF_RES.dos
	echo "set key left top">>IPERF_RES.dos

	while [ $i -lt $j ]; do
	
		if [ $i -eq 0 ]; then
	                echo "p '${RES_LIST[$i]}.dat' u 1:2 w l lt $i lc $i lw 2 t '${RES_LIST[$i]}', \\">>IPERF_RES.dos
		else
			echo "'${RES_LIST[$i]}.dat' u 1:2 w l lt $i lc $i lw 2 t '${RES_LIST[$i]}', \\">>IPERF_RES.dos
		fi
		
		rm ${RES_LIST[$i]}
	
		let i=i+1		
	done
	
	echo "'${RES_LIST[$i]}.dat' u 1:2 w l lt $i lc $i lw 2 t '${RES_LIST[$i]}'">>IPERF_RES.dos
	rm ${RES_LIST[$i]}

	#awk -f MTU_BW.awk  ${RES_LIST[i]} > ${RES_LIST[$i]}.dat

	gnuplot IPERF_RES.dos
		
	convert -density 300 -trim IPERF_RES.eps -quality 100 graph-temp.jpg
	convert -resize 600x400 graph-temp.jpg graph.jpg
	#scp graph.jpg nml@203.237.53.202:workspace/openflow_gui/images/
	#scp graph.jpg root@NML:images/
	cp graph.jpg ../images/
	cd ..
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
iperf_experiment


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
echo -e "Network Resource Status for Smartx-BPlus-PKS  		: $TUNNEL_RESULT_PKS\n"
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
