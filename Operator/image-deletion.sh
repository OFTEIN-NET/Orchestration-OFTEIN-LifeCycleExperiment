#!/bin/bash
#
# Name          : image-deletion.sh
# Description   : Script for OF@TEIN Infrastructure Experiment Customs Image Deletion
#
# Created by    : TEIN_GIST@nm.gist.ac.kr
# Version       : 0.1
# Last Update   : March, 2014
#
# Main Script

PARAMETER=2

if [ $# -ne $PARAMETER ]; then

	echo -e ""
	echo -e "Usage 	: ./image-deletion.sh <countryID> <vm_name> \n"
	echo -e "countryID	site name <GIST, MYREN, MY, ID, PH, VN ,TH, PKS>"
	echo -e "vm_name		Unique name (it will added with countryID)"
	exit 0

else

	# Check the VM name and Create if not exists

	echo -e "Checking the VM Status ..."
	VM=$(ssh tein@Smartx-BPlus-$1 "sudo xl list | grep $2")

	if [ "$VM" = "" ]; then
	
		echo -e "$2 Virtual Machine at $1 Site is not running ..."
		echo -e "Delete $2 Virtual Machine at $1 Site ..."
		ssh tein@Smartx-BPlus-$1 "sudo xen-delete-image --dir=images --hostname=$2-$1"
	
	else
	
		echo -e "$2-$1 Virtual machine is still running!!!"
		echo -e "Try to stop the virtual machine"
		
		ssh tein@Smartx-BPlus-$1 "sudo xl -f destroy $2-$1"
		
		VM2=$(ssh tein@Smartx-BPlus-$1 "sudo xl list | grep $2-$1")

		if [ "$VM2" = "" ]; then
	
			echo -e "Delete $2 Virtual Machine at $1 Site ..."
			ssh tein@Smartx-BPlus-$1 "sudo xen-delete-image --dir=images --hostname=$2-$1"
	
		else
	
			echo -e "$2-$1 Virtual machine can't be deleted!!!"
		
		fi
			
	fi

fi

