#!/bin/bash

if [ ! -e '/tmp/inet' ];then
    if [[ $( ping -c 1 -q 92.247.16.194 | grep -oP '\d+(?=% packet loss)') == 0 ]];then
	touch /tmp/inet && echo "state=main" > /tmp/inet
    else
	touch /tmp/inet && echo "state=backup" > /tmp/inet
    fi
fi

source /tmp/inet

if [[ $(ping -c 1 -q 92.247.16.193 | grep -oP '\d+(?=% packet loss)') == 100 ]];then

    if [ $state = "backup" ];then exit
	else
	nmcli d wifi connect VivaBackup password allterc0
	sleep .5
	route del default
	sleep .5
	route add default gw 192.168.5.1 metric 0
	echo "state=backup" > /tmp/inet
    now=$(date)
	echo "Switching to Backup Internet @ $now ..." >> /var/log/inet.log
    fi

elif [[ $(ping -c 1 -q 92.247.16.194 | grep -oP '\d+(?=% packet loss)') == 0 ]];then

    if [ $state = "main" ];then exit
	else
	nmcli d disconnect wlp2s0
	sleep .5
	route add default gw 192.168.2.2 metric 0
	echo "state=main" > /tmp/inet


    now=$(date)
    echo "Switching to Main Internet @ $now ..." >> /var/log/inet.log
    fi

fi