#!/bin/bash
#
# Name          : image-preparation.sh
# Description   : Script for OF@TEIN Infrastructure Experiment Customs Image Creation
#
# Created by    : TEIN_GIST@nm.gist.ac.kr
# Version       : 0.1
# Last Update   : March, 2014
#
# Main Script

PARAMETER=5

if [ $# -ne $PARAMETER ]; then

	echo -e ""
	echo -e "Usage 	: ./image-preparation.sh <countryID> <vm_name> <ip_address> <netmask> <gateway> \n"
	echo -e "countryID	site name <GIST, MYREN, MY, ID, PH, VN ,TH, PKS>"
	echo -e "vm_name		Unique name (it will added with countryID)"
	echo -e "ip_address	VM Management IP address"
	echo -e "netmask		VM Subnet Mask from Management IP address"
	echo -e "vm_name		VM Gateway IP address for access from outside\n"
	exit 0

else

	# Check the VM name and Create if not exists

	echo -e "Checking the Running VM with the same name ..."
	VM=$(ssh tein@Smartx-BPlus-$1 "sudo xl list | grep $2")

	if [ "$VM" = "" ]; then
	
		echo -e "Create $2 Virtual Machine at $1 Site ..."
		ssh tein@Smartx-BPlus-$1 "sudo xen-create-image --hostname=$2-$1 --size=2Gb --noswap --ip=$3 --netmask=$4 --gateway=$5 --dir=images --memory=2Gb --arch=amd64 --dist=precise --install-method=tar --install-source=/opt/ubuntu-12.04.tar  --genpass=0 --password=netmedia --bridge=xenbr0 --force"
		ssh tein@Smartx-BPlus-$1 "cp /etc/xen/$2-$1.cfg ."
		TEMP="\"s/xenbr0/xenbr0','ip=192.168.2.170,bridge=xenbr1/\""
        ssh tein@Smartx-BPlus-$1 "sed -i $TEMP $2-$1.cfg"
	
	else
	
		echo -e "$2-$1 Virtual Machine already exists at $1 Site!!!"
		echo -e "Please try use another hostname!!!"
		exit 0
	fi

	echo -e "Starting the Virtual Machine $2-$1 at $1 Site"
	
	ssh tein@SmartX-BPlus-$1 "sudo xl -f create $2-$1.cfg"

	echo -e "Checking Virtual Machine $2-$1 is running  ..."

	VM=$(ssh tein@Smartx-BPlus-$1 "sudo xl list | grep $2")

        if [ "$VM" = "" ]; then

              echo -e "Virtual Machine at $2-$1 is not running !!! "
	      exit 0

	else
              echo -e "Virtual Machine at $2-$1 is running. "
	fi

fi

