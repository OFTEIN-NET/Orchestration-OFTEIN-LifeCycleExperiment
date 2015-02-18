ssh netcs@exp-vm-Smartx-BPlus-GIST 'killall vlc'
ssh netcs@exp-vm-Smartx-BPlus-MYREN 'killall vlc'
#ssh netcs@exp-vm-Smartx-BPlus-ID 'killall vlc'
ssh root@exp-vm-Smartx-BPlus-GIST 'killall ping'
ssh root@exp-vm-Smartx-BPlus-MYREN 'killall ping'
#ssh root@exp-vm-Smartx-BPlus-ID 'killall ping'
kill -9 $(ps -aux | grep java | awk '{print $2}')
kill -9 $(ps -aux | grep sflow | awk '{print $2}')
