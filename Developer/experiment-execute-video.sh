#!/bin/bash
#
# Script Name	: vlc_experiment_start.sh
# Description	: Script for execute vlc video server and client remotely
# Version		: 0.1
# Last Update	: June 2014
#

SDNTOOLSVR="103.22.221.53"
LOGDIR="log"
LOGFILE=experiment.video.`date +%Y%m%d.%H%M%S`.log
SVR_SITES="MYREN" # separated by spaces

# Start VLC video server in the experiment VM (remote site) and run it at background
#
# Current testing at "TEST" and "ID" site
#

function vlc_check {

echo -e "\n"
echo -e "----------------------------------------"
echo -e "| Checking VLC Packages for Experiment |"
echo -e "----------------------------------------"

for countryID in $SVR_SITES 
	do
		echo -e "\nChecking VLC Packages for exp-vm-Smartx-BPlus-$countryID"
		echo -e "---------------------------------------------------\n"
		
 		VLC=`ssh root@exp-vm-smartx-bplus-$countryID 'dpkg -l | grep vlc'`

		if [ "${VLC:-null}" = null ]; then
			echo -e "VLC Packages are not installed !!!"
			VLC_RESULT="FAILED"
						
			echo -e "Try to install packages...."
			
			ssh netcs@$SDNTOOLSVR "knife bootstrap exp-vm-SmartX-BPlus-$countryID -x root -r 'recipe[smartx-bp-function::vlc]'"

			#ssh root@exp-vm-smartx-bplus-$countryID "apt-get --force-yes --yes install vlc" 
			#ssh root@exp-vm-smartx-bplus-$countryID "scp netcs@SDNTOOLSVR:Exp-LifeCycle-Mgmt/nongak.sd ." 
			#ssh root@exp-vm-smartx-bplus-$countryID "scp netcs@SDNTOOLSVR:Exp-LifeCycle-Mgmt/start_vlc.sh ." 
			
			VLC2=`ssh root@exp-vm-smartx-bplus-$countryID 'dpkg -l | grep vlc'`
			
			if [ "${VLC2:-null}" = null ]; then
				echo -e "VLC Packages are failed to installed !!!"
				echo -e "Please contact your Administrator.\n"
				VLC_RESULT="FAILED"
			else
				echo -e "VLC Packages are successfully installed.\n"
				VLC_RESULT="OK"
			fi
			
		else
			echo -e "VLC Packages are installed.\n"
			VLC_RESULT="OK"

		fi

	echo -e "Checking done for exp-vm-SmartX-BPlus-$countryID.\n"
	
	if [ "$VLC_RESULT" =	"OK" ]; then
		export VLC_RESULT_$countryID="\033[32m[$VLC_RESULT]\033[0m"
	else
		export VLC_RESULT_$countryID="\033[31m[$VLC_RESULT]\033[0m"
	fi
		
	done

echo -e "\nVLC Packages Checking Done.\n"

}

function video_server_start {

echo -e "\n"
echo -e "--------------------------------------------------"
echo -e "| Check or Start VLC Video Server for Experiment |"
echo -e "--------------------------------------------------"

for countryID in $SVR_SITES
	do
		echo -e "\nChecking VLC Video Server for exp-vm-Smartx-BPlus-$countryID"
		echo -e "--------------------------------------------------------\n"
		
 		VS=`ssh root@exp-vm-smartx-bplus-$countryID 'pgrep vlc'`

		if [ "${VS:-null}" = null ]; then
			echo -e "Video Server is not started !!!"
			VS_RESULT="FAILED"
						
			echo -e "Try to start Video Server...."
			ssh netcs@exp-vm-SmartX-BPlus-$countryID './start_vlc.sh' &
			sleep 5
			kill -2 $!
			
			VS2=`ssh root@exp-vm-smartx-bplus-$countryID 'pgrep vlc'`
			
			if [ "${VS2:-null}" = null ]; then
				echo -e "Video Server is failed to start !!!"
				echo -e "Please contact your Administrator.\n"
				VS_RESULT="FAILED"
			else
				echo -e "Video Server is started.\n"
				VS_RESULT="OK"
			fi
			
		else
			echo -e "Video Server is started.\n"
			VS_RESULT="OK"

		fi

	echo -e "Checking done for exp-vm-SmartX-BPlus-$countryID.\n"
	
	if [ "$VS_RESULT" =	"OK" ]; then
		export VS_RESULT_$countryID="\033[32m[$VS_RESULT]\033[0m"
	else
		export VS_RESULT_$countryID="\033[31m[$VS_RESULT]\033[0m"
	fi
		
	done

echo -e "\nVideo Server Check or Start is Done.\n"

}


# Start VLC video client in the GIST site and run it at background
#
# Because the experiment VM didn't have any GUI packages, 
# redirect the display into monitoring terminal with X11 through SSH
#

function video_client_start {

echo -e "----------------------------------------------"
echo -e "| Check or Start Video Client for Experiment |"
echo -e "----------------------------------------------"
		
VC=`ssh root@exp-vm-smartx-bplus-GIST 'pgrep vlc'`

if [ "${VC:-null}" = null ]; then
	
	echo -e "Video Client is not started !!!"
	VC_RESULT="FAILED"
					
	echo -e "Try to start Video CLient...."
    echo -e "Start the VLC Client for SmartX-BPlus-MYREN Stream..."
	ssh -X netcs@exp-vm-SmartX-BPlus-GIST 'vlc --loop http://192.168.2.120:8080 --intf rc --rc-host=exp-vm-Smartx-BPlus-GIST:8080' &
	#sleep 2
	#echo -e "Start the VLC Client for SmartX-BPlus-ID Stream..."
	#ssh -X netcs@exp-vm-SmartX-BPlus-GIST 'vlc --loop http://192.168.2.100:8080 --intf rc --rc-host=exp-vm-Smartx-BPlus-GIST:8080' &

	sleep 5

	VC2=`ssh root@exp-vm-smartx-bplus-GIST 'pgrep vlc'`

	if [ "${VC2:-null}" = null ]; then
		
		echo -e "Video Client is failed to start !!!"
		echo -e "Please contact your Administrator.\n"
		VC_RESULT="FAILED"
	else
		echo -e "Video Client is started.\n"
		VC_RESULT="OK"
	fi

else
	echo -e "Video Client is started.\n"
	VC_RESULT="OK"
fi
	
if [ "$VC_RESULT" =	"OK" ]; then
	export VC_RESULT_GIST="\033[32m[$VC_RESULT]\033[0m"
else
	export VC_RESULT_GIST="\033[31m[$VC_RESULT]\033[0m"
fi
	
echo -e "\nVideo Client Check or Start is Done.\n"
	
}


function video_measurement {

echo -e "---------------------------------------------"
echo -e "| Starting Measurement for Video Experiment |"
echo -e "---------------------------------------------"
		
if [ "$VC_RESULT" =	"OK" ]; then
	
	echo -e "Video Streaming is working.\n"
	echo -e "Start Video Performance Measurement for SmartX-BPlus Stream..."
	#ssh netcs@exp-vm-SmartX-BPlus-GIST 'bash ./openrtsp.sh TS'
	#ssh netcs@exp-vm-SmartX-BPlus-GIST 'bash ./openrtsp.sh ID'
	VC_MEASURE="OK"
	
else
	echo -e "Video Streaming is not running !!!"
	echo -e "Try to verify with Video Client First !!!"
	VC_MEASURE="FAILED"
	
fi
	
if [ "$VC_RESULT" =	"OK" ]; then
	export VC_MEASURE_GIST="\033[32m[$VC_RESULT]\033[0m"
else
	export VC_MEASURE_GIST="\033[31m[$VC_RESULT]\033[0m"
fi

#cd workspace/OFTEIN-Visibility
rm vlc-stats.txt
#rm sflow-dump.json
java -jar vlc-client-nogui.jar > vlc-stats.txt &
#./sflow.sh &

echo -e "\nVideo Performance Measurement is Done.\n"
	
}



#
# Main Script
#

echo -e "\n"
echo -e "############################################"
echo -e "# Automatic Execution for Video Experiment #"
echo -e "############################################"

touch $LOGDIR/$LOGFILE

vlc_check
sleep 5
video_server_start
sleep 5
video_client_start
sleep 5 
video_measurement
sleep 10


echo -e "\nAutomatic Execution for Video Experiment is Done.\n"
echo -e "############################"
echo -e "# Execution Result Summary #"
echo -e "############################\n"

echo -e "Video Packages Check for exp-vm-Smartx-BPlus-GIST 	: $VLC_RESULT_GIST"
echo -e "Video Packages Check for exp-vm-Smartx-BPlus-TEST 	: $VLC_RESULT_TEST"
echo -e "Video Packages Check for exp-vm-Smartx-BPlus-ID 	: $VLC_RESULT_ID\n"

echo -e "Video Server Execution for exp-vm-Smartx-BPlus-TEST	: $VS_RESULT_TEST"
echo -e "Video Server Execution for exp-vm-Smartx-BPlus-ID	: $VS_RESULT_ID"

echo -e "Video Client Execution for exp-vm-Smartx-BPlus-GIST	: $VC_RESULT_GIST"

#echo -e "Video Measurement for exp-vm-Smartx-BPlus-GIST		: $VC_MEASURE_GIST"

echo -e "\n"
echo -e "Please check the \"$LOGFILE\" for detail result."
echo -e "\n"
