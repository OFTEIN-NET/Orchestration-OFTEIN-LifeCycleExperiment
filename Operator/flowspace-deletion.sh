#!/bin/bash
#
# Name          : flowspace-preparation.sh
# Description   : Script for OF@TEIN Infrastructure Experiment Slice and FlowSpace Configuration
#
# Created by    : TEIN_GIST@nm.gist.ac.kr
# Version       : 0.1
# Last Update   : March, 2014
#
# Main Script

# Required Parameter : 4 [Slice Name, Controller, VLAN]

FLOWVISOR="103.22.221.52"

PARAMETER=1

if [ $# -ne $PARAMETER ]; then

	echo -e ""
	echo -e "Usage 	: ./flowspace-preparation.sh [Slice_Name]\n"
	echo -e "Available Commands are: \n"
	echo -e "Slice_Name	Unique Slice Name for FlowSpace"
	exit 0
	

else

	# Check the VM name and Create if not exists

	echo -e "Checking the Slice and FlowSpace with the same name ..."
	
	for FLOWPARAM in $1 
	
		do
			if [[ -n $(ssh netcs@$FLOWVISOR 'fvctl-json --passwd-file=passwd list-flowspace' | grep $FLOWPARAM) ]]; then
						export FLOWPARAM2="\033[32m[$FLOWPARAM]\033[0m"
						echo -e "Parameter $FLOWPARAM2 is exist !!!"
						
			else
						export FLOWPARAM2="\033[31m[$FLOWPARAM]\033[0m"
						echo -e "Parameter $FLOWPARAM2 is not exist !!!"
						exit 0
			fi

		done 

	echo -e "Creating Slice and Adding FlowSpace ..."

	ssh netcs@$FLOWVISOR "fvctl-json --passwd-file=passwd remove-flowspace $1-FLOWSPACE"	
	ssh netcs@$FLOWVISOR "fvctl-json --passwd-file=passwd remove-slice $1"
	
fi

