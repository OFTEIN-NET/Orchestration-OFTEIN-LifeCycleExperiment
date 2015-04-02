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

PARAMETER=3

if [ $# -ne $PARAMETER ]; then

	echo -e ""
	echo -e "Usage 	: ./flowspace-preparation.sh [Slice_Name] [Controller] [VLAN_ID]\n"
	echo -e "Available Commands are: \n"
	echo -e "Slice_Name	Unique Slice Name for FlowSpace"
	echo -e "Controller	IP address"
	echo -e "VLAN_ID		Unique VLAN for the Slice"
	exit 0
	

else

	# Check the VM name and Create if not exists

	echo -e "Checking the Slice and FlowSpace with the same name ..."

		
	for FLOWPARAM in $1 #$3
	
		do
			if [[ -n $(ssh netcs@$FLOWVISOR 'fvctl-json --passwd-file=passwd list-flowspace' | grep $FLOWPARAM) ]]; then
						export FLOWPARAM2="\033[31m[$FLOWPARAM]\033[0m"
						echo -e "Parameter $FLOWPARAM2 is already exist !!!"
						exit 0
			else
						export FLOWPARAM2="\033[32m[$FLOWPARAM]\033[0m"
						echo -e "Parameter $FLOWPARAM2 is available."
			fi

		done 

	echo -e "Creating Slice and Adding FlowSpace ..."
	
	ssh netcs@$FLOWVISOR "fvctl-json --passwd-file=passwd add-slice $1 tcp:$2:6633 tein-gist@nm.gist.ac.kr"
	ssh netcs@$FLOWVISOR "fvctl-json --passwd-file=passwd add-flowspace $1-FLOWSPACE all 10 dl_vlan=$3 $1=4"
	
	sleep 10
	echo -e "Initialize Node information on Controller ..."

	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:01/property/description/MYREN1
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:00/property/description/MYREN2
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:03/property/description/ID1
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:04/property/description/ID2
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:05/property/description/MY1
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:06/property/description/MY2
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:07/property/description/PKS1
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:08/property/description/PKS2
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:09/property/description/GIST_test1
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:10/property/description/GIST_test2
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:11/property/description/TH1
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:12/property/description/TH2
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:13/property/description/VN1
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:14/property/description/VN2
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:15/property/description/GJ1
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:16/property/description/GJ2
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:17/property/description/PH1
	curl --user "admin":"admin" -H "Accept: application/json" -H "Content-type: application/json" -X PUT http://$2:8080/controller/nb/v2/switchmanager/default/node/OF/00:00:11:11:11:11:11:18/property/description/PH2
fi


