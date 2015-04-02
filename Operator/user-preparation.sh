#!/bin/bash

#
# Name          : user-preparation.sh
# Description   : Script for OF@TEIN Infrastructure Experiment Account Creation 
#
# Created by    : TEIN_GIST@nm.gist.ac.kr
# Version       : 0.2
# Last Update   : March, 2014
#

if [ "$1" = "" ]; then

echo -e "\nUsage : ./user-preparation.sh <username>"
echo -e "username	experimenter user\n"
exit 0

else

FLOWVISOR="103.22.221.52"
USERCTRL="103.22.221.140"
SDNTOOLSVR="103.22.221.53"

# Add User and Create Home Directory

useradd -d /home/$1 -m -s /bin/bash $1
passwd $1
mkdir /home/$1/log
chown -R $1:$1 /home/$1/log

# Copy script for user and change owner+permission

cd /home/$1
cp /home/netcs/Exp-LifeCycle-Mgmt/experiment-check.template.sh .
cp /home/netcs/Exp-LifeCycle-Mgmt/experiment-cleanup.template.sh .
cp /home/netcs/Exp-LifeCycle-Mgmt/image-preparation.sh .
cp /home/netcs/Exp-LifeCycle-Mgmt/image-deletion.sh .

# RSA Key Distribution for non-interactive remote access

su - $1 -c 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'
ssh-copy-id -i /home/$1/.ssh/id_rsa netcs@$FLOWVISOR
ssh-copy-id -i /home/$1/.ssh/id_rsa netcs@$SDNTOOLSVR
ssh-copy-id -i /home/$1/.ssh/id_rsa netcs@$USERCTRL

for countryID in GIST TEST ID MY MYREN TH VN PKS PH
do

  ssh-copy-id -i /home/$1/.ssh/id_rsa tein@SmartX-BPlus-$countryID

done

cp /home/netcs/.ssh/known_hosts /home/$1/.ssh/known_hosts
chmod 600 /home/$1/.ssh/known_hosts
chown $1:$1 /home/$1/.ssh/known_hosts

fi

