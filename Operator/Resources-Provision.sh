#!/bin/bash

#
# Name 			: admin-check.sh
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
FLOWSPACE="192.168.2.0"
LOGDIR=log
LOGFILE=admin.check.`date +%Y%m%d.%H%M%S`.log
B_SITES="" # separated by spaces
BP_SITES="TEST" #GIST PH ID MYREN MY PKS" # separated by spaces

# Function Definition
# ===================
#
# [1] FlowSpace Resource Checking
#

function check_flowvisor {

	echo -e "\n"
	echo -e "------------------------------------------------"
	echo -e "| Checking FlowVisor Service and Configuration |"
	echo -e "------------------------------------------------"
	echo -e "\n"

	FV_CHECK=`ssh netcs@$FLOWVISOR /etc/init.d/flowvisor status | grep running`
	
	if [ "${FV_CHECK:-null}" != null ]; then
        	echo "FlowVisor is running."
			FV_RESULT="OK"
	else
        	echo "FlowVisor is stopped."
        	echo "Try to start FlowVisor..."
        	ssh netcs@$FLOWVISOR '/etc/init.d/flowvisor start' >> $LOGDIR/$LOGFILE 2>&1
		
		FV_CHECK_2=`ssh netcs@$FLOWVISOR /etc/init.d/flowvisor status | grep running`
		
	if [ "${FV_CHECK_2:-null}" != null ]; then
			echo "FlowVisor is started."
			FV_RESULT="OK"
		else
			echo "Failed to start the FlowVisor. !!!"
			echo "Check the FlowVisor Configuration !!!"
			FV_RESULT="FAILED"
		fi	
		
	fi

	
	if [ $FV_RESULT = "OK" ]; then
		export FV_RESULT="\033[32m[$FV_RESULT]\033[0m"
	else
		export FV_RESULT="\033[31m[$FV_RESULT]\033[0m"
	fi
	
}
#
# [2] Capsulator (Tunnel) Checking
#

function check_tunnel {

echo -e "\n"
echo -e "--------------------------------"
echo -e "| Capsulator (Tunnel) Checking |"
echo -e "--------------------------------"
echo -e "\n"

for countryID in $B_SITES MY2
	do
		echo -e "Checking Tunnel for Smartx-B-$countryID"
		echo -e "--------------------------------"
 
		TUNNEL_NAME=GJ"$countryID"
 
		TUNNEL=`cat ~/AdminSDNController/Tunnel/active_tunnel.list | grep $TUNNEL_NAME`

		if [ "${TUNNEL:-null}" = null ]; then
			echo -e "Tunnel for Smartx-B-$countryID is Down !!!"
			echo -e "Try to initiate the tunnel...\n"
			#ssh netcs@$SDNTOOLSVR ls
			TUNNEL2=`cat ~/AdminSDNController/Tunnel/active_tunnel.list | grep $TUNNEL_NAME`
			
			if [ "${TUNNEL2:-null}" = null ]; then
				echo -e "Failed to initiate the tunnel for Smartx-B-$countryID...\n"
				TUNNEL_RESULT="FAILED"
			else
				echo -e "Tunnel for Smartx-B-$countryID is Up.\n"
				TUNNEL_RESULT="OK"
			fi
			
		else
			echo -e "Tunnel for Smartx-B-$countryID is Up.\n"
			TUNNEL_RESULT="OK"

		fi

	echo -e "\nChecking done for Smartx-B-$countryID.\n"
	
	if [ "$TUNNEL_RESULT" =	"OK" ]; then
		export TUNNEL_RESULT_$countryID="\033[32m[$TUNNEL_RESULT]\033[0m"
	else
		export TUNNEL_RESULT_$countryID="\033[31m[$TUNNEL_RESULT]\033[0m"
	fi
		
	done

echo -e "Capsulator (Tunnel) Checking Done.\n"

}

#
# [3] OpenFlow Switch(OVS or HP Switch) Checking
#

function check_switch {

echo -e "\n"
echo -e "------------------------------------------------"
echo -e "| OpenFlow Switch (HP Switch and OVS) Checking |"
echo -e "------------------------------------------------"
echo -e "\n"

for countryID in $B_SITES 
	do

	echo -e "Checking OpenFlow Switch for Smartx-B-$countryID"
	echo -e "----------------------------------------"
 
		OF_SWITCH=`ping HP-$countryID -c 1 | grep icmp_req`
	
		if [ "${OF_SWITCH:-null}" = null ]; then
		
			echo -e "OpenFlow Switch (HP Switch) is Down !!!"
			echo -e "Please check the PHysical or network connection !!!\n"
			SWITCH_RESULT="FAILED"	
		else
			echo -e "OpenFlow Switch (HP Switch) is Up and Running.\n"
			SWITCH_RESULT="OK"	
		fi
	
	if [ "$SWITCH_RESULT" =	"OK" ]; then
		export SWITCH_RESULT_$countryID="\033[32m[$SWITCH_RESULT]\033[0m"
	else
		export SWITCH_RESULT_$countryID="\033[31m[$SWITCH_RESULT]\033[0m"
	fi
	
	done

for countryID in $BP_SITES
	do

	echo -e "Checking OpenFlow Switch for Smartx-BPlus-$countryID"
	echo -e "--------------------------------------------"
 
		OF_SWITCH=`ssh tein@Smartx-BPlus-$countryID 'ifconfig -a | grep br2' ; ssh tein@Smartx-BPlus-$countryID 'ifconfig -a| grep br1'`
	
		if [ "${OF_SWITCH:-null}" = null ]; then
		
			echo -e "OpenFlow Switch (OVS Bridge : br1 and br2) is Down !!!"
			echo -e "Please check the the OVS configuration !!!\n"
			SWITCH_RESULT="FAILED"	
		else
			echo -e "OpenFlow Switch (OVS Bridge : br1 and br2) is Up and Running.\n"
			SWITCH_RESULT="OK"	
		fi
	
	if [ "$SWITCH_RESULT" =	"OK" ]; then
		export SWITCH_RESULT_$countryID="\033[32m[$SWITCH_RESULT]\033[0m"
	else
		export SWITCH_RESULT_$countryID="\033[31m[$SWITCH_RESULT]\033[0m"
	fi
	
	done	
	
echo -e "OpenFlow Switch Checking Done.\n"		
		
}
		
#
# [4] Worker (VM Manager) Checking
#

function check_vmm {

	echo -e "\n"
	echo -e "------------------------------------"
	echo -e "| Worker (XEN Hypervisor) Checking |"
	echo -e "------------------------------------"
	echo -e "\n"

	for countryID in $B_SITES 
	do
		echo -e "Checking for Smartx-B-$countryID"
		echo -e "------------------------"
 
		PING=`ping Smartx-B-$countryID -c 1 | grep icmp_req`

		if [ "${PING:-null}" = null ]; then
			echo "Host Smartx-B-$countryID is not reachable !!!"
			VMM_RESULT="FAILED"
		else
			echo "Host Smartx-B-$countryID is reachable."
    
			XEN=`ssh root@Smartx-B-$countryID 'xm list | grep Domain-0'`
    
			if [ "${XEN:-null}" = null ]; then
				echo "XEN Domain-0 is not running !!!"
				echo "Try to start XEN Domain-0 ..."
				ssh root@Smartx-B-$countryID '/etc/init.d/xend start'
			
				XEN2=`ssh root@Smartx-B-$countryID 'xm list | grep Domain-0'`
    
				if [ "${XEN2:-null}" = null ]; then
					echo "XEN Domain-0 can't be started !!!"
					echo -n "Check and Recover the Worker Installation [Yes/No]? "
					read RECOVER
					
					while [[ "$RECOVER" != "Yes" && "$RECOVER" != "No" ]]; do
						echo -n "Please answer [Yes] or [No] :  "
						read RECOVER
					done
										
						if [ $RECOVER = "Yes" ]; then
							echo "Starting Checking and Recovery using Chefs...."
							knife bootstrap Smartx-B-$countryID -x root -r 'recipe[smartx-b-worker::worker-config]'
							VMM_RESULT="OK"
							
						elif [ $RECOVER = "No" ]; then
							echo "Skip checking and Recovery using Chefs."
							VMM_RESULT="FAILED"
						fi

				else
					echo "XEN Domain-0 is started ..."
					VMM_RESULT="OK"
				fi
									
			else
				echo "XEN Domain-0 is running ..."
				VMM_RESULT="OK"
			fi
    	
		fi

	echo -e "\nChecking done for Smartx-B-$countryID.\n"
	
	if [ "$VMM_RESULT" =	"OK" ]; then
		export VMM_RESULT_$countryID="\033[32m[$VMM_RESULT]\033[0m"
	else
		export VMM_RESULT_$countryID="\033[31m[$VMM_RESULT]\033[0m"
	fi
	
	done
	
    
	for countryID in $BP_SITES
	do
		echo -e "Checking for Smartx-BPlus-$countryID"
		echo -e "-----------------------------"
 
		PING=`ping Smartx-BPlus-$countryID -c 1 | grep icmp_req`

		if [ "${PING:-null}" = null ]; then
			echo "Host Smartx-BPlus-$countryID is not reachable !!!"
			VMM_RESULT="FAILED"
		else
			echo "Host Smartx-BPlus-$countryID is reachable."
    
			XEN=`ssh tein@Smartx-BPlus-$countryID 'sudo xl list | grep Domain-0'`
			
			if [ "${XEN:-null}" = null ]; then
				echo -e "\nXEN Domain-0 (Hypervisor) is problem !!!"
				echo -e "Try to check XEN Hypervisor Services...\n"
				
				XEND=1

				for XENPROC in xenwatch xenbus xen_pci xenstored xenconsoled xen-domid

				do
					if [[ -n $(ssh tein@Smartx-BPlus-$countryID 'ps -U root -u root u' | grep $XENPROC) ]]; then
						export XENPROC2="\033[32m[$XENPROC]\033[0m"
						echo -e "$XENPROC2 is running..."
					else
						export XENPROC2="\033[31m[$XENPROC]\033[0m"
						echo -e "$XENPROC2 is not running!!!"
						XEND=0
					fi

				done

				if [ $XEND=0 ]; then
					echo -e "\nSome XEN services or packages are missing !!!"
					echo -n "Recover XEN Hypervisor packages and services [Yes/No]? "
					read RECOVER
					
					while [[ "$RECOVER" != "Yes" && "$RECOVER" != "No" ]]; do
						echo -n "Please answer [Yes] or [No] :  "
						read RECOVER
					done
										
						if [ $RECOVER = "Yes" ]; then
							echo "Starting Checking and Recovery using Chefs...."
							knife bootstrap Smartx-BPlus-$countryID -x root -r 'recipe[smartx-bp-install::xen-4.3-install],recipe[smartx-bp-config::xen]'
							VMM_RESULT="OK"
							
						elif [ $RECOVER = "No" ]; then
							echo "Skip checking and Recovery using Chefs."
							VMM_RESULT="FAILED"
						fi

				else
					echo "XEN Domain-0 is started ..."
					VMM_RESULT="OK"
				fi
									
			else
				echo "XEN Domain-0 is running ..."
				VMM_RESULT="OK"
			fi
    	
		fi

	echo -e "\nChecking done for Smartx-BPlus-$countryID.\n"
	
	if [ "$VMM_RESULT" =	"OK" ]; then
		export VMM_RESULT_$countryID="\033[32m[$VMM_RESULT]\033[0m"
	else
		export VMM_RESULT_$countryID="\033[31m[$VMM_RESULT]\033[0m"
	fi
	
	done	
	
echo -e "VMM (XEN Hypervisor) Checking is done...\n"

}


#
# Main Script
#

echo -e "\n"
echo -e "#########################################"
echo -e "# Checking SDN Infrastructure Resources #"
echo -e "#########################################"

touch $LOGDIR/$LOGFILE

for countryID in GIST ID MY TH PH VN VT MYREN MY2 PKS
do

	export TUNNEL_RESULT_$countryID="[N/A]"
	export SWITCH_RESULT_$countryID="[N/A]"
	export VMM_RESULT_$countryID="[N/A]"
	export EXP_RESULT_$countryID="[N/A]"
	
done

check_flowvisor
sleep 1
check_tunnel
sleep 1
check_switch
sleep 2
check_vmm

echo -e "Checking SDN Infrastructure Resource is Done.\n"
echo -e "###########################"
echo -e "# Checking Result Summary #"
echo -e "###########################\n"
echo -e "FlowVisor Status					: $FV_RESULT\n"
echo -e "Capsulator (Tunnel) Status for Smartx-BPlus-GIST 	: $TUNNEL_RESULT_GIST"
echo -e "Capsulator (Tunnel) Status for Smartx-BPlus-ID 		: $TUNNEL_RESULT_ID"
echo -e "Capsulator (Tunnel) Status for Smartx-BPlus-MY 		: $TUNNEL_RESULT_MY"
echo -e "Capsulator (Tunnel) Status for Smartx-BPlus-MYREN 	: $TUNNEL_RESULT_MY2"
echo -e "Capsulator (Tunnel) Status for Smartx-B-TH 		: $TUNNEL_RESULT_TH"
echo -e "Capsulator (Tunnel) Status for Smartx-B-PH 		: $TUNNEL_RESULT_PH"
echo -e "Capsulator (Tunnel) Status for Smartx-B-VN 		: $TUNNEL_RESULT_VT"
echo -e "Capsulator (Tunnel) Status for Smartx-B-PKS 		: $TUNNEL_RESULT_PKS\n"
echo -e "OpenFlow Switch Status for Smartx-BPlus-GIST	 	: $SWITCH_RESULT_GIST"
echo -e "OpenFlow Switch Status for Smartx-BPlus-ID 		: $SWITCH_RESULT_ID"
echo -e "OpenFlow Switch Status for Smartx-BPlus-MY 		: $SWITCH_RESULT_MY"
echo -e "OpenFlow Switch Status for Smartx-BPlus-MYREN		: $SWITCH_RESULT_MYREN"
echo -e "OpenFlow Switch Status for Smartx-B-TH 			: $SWITCH_RESULT_TH"
echo -e "OpenFlow Switch Status for Smartx-B-PH 			: $SWITCH_RESULT_PH"
echo -e "OpenFlow Switch Status for Smartx-B-VN			: $SWITCH_RESULT_VT"
echo -e "OpenFlow Switch Status for Smartx-B-PKS 		: $SWITCH_RESULT_PKS\n"
echo -e "VMM (XEN Hypervisor) Status for Smartx-BPlus-GIST	: $VMM_RESULT_GIST"
echo -e "VMM (XEN Hypervisor) Status for Smartx-BPlus-ID		: $VMM_RESULT_ID"
echo -e "VMM (XEN Hypervisor) Status for Smartx-BPlus-MY		: $VMM_RESULT_MY"
echo -e "VMM (XEN Hypervisor) Status for Smartx-BPlus-MYREN	: $VMM_RESULT_MYREN"
echo -e "VMM (XEN Hypervisor) Status for Smartx-B-TH		: $VMM_RESULT_TH"
echo -e "VMM (XEN Hypervisor) Status for Smartx-B-PH		: $VMM_RESULT_PH"
echo -e "VMM (XEN Hypervisor) Status for Smartx-B-VN		: $VMM_RESULT_VN"
echo -e "VMM (XEN Hypervisor) Status for Smartx-B-PKS 			: $VMM_RESULT_PKS"
echo -e "\n"
echo -e "Please check the \"$LOGFILE\" for detail result."
echo -e "\n"
