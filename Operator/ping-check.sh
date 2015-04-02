#!/bin/bash
#
# Script for checking ping
#

BP_SITES="MYREN MY TH PKS ID PH VN TEST"
LOG="/home/netcs/Exp-LifeCycle-Mgmt/result/ping.log"
TIME=`date`

echo -n $TIME >> $LOG 

for countryID in $BP_SITES
do

echo -n "," >> $LOG

VM_PING2=`ping Smartx-BPlus-$countryID -c 1 | grep icmp_req`

        if [ "${VM_PING2:-null}" = null ]; then
                echo -n "DOWN" >> $LOG 
        else
		echo -n "UP" >> $LOG 

        fi

done

echo "" >> $LOG 
