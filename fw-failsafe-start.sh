#!/bin/bash
cd /root

let IPTABLE_COUNT=$(iptables -L -n | wc -l)

if [[ $IPTABLE_COUNT < 10 ]] ; then 
	echo "It appears your iptables have been reset, no need to execute this script"
	exit 9
fi

if [ -e  watchdog ] ; then
	rm watchdog
fi

echo "Waiting 60 seconds for watchdog file to appear from remote, you did start one right?"
sleep 60
if [[ ! -e watchdog ]] ; then
	echo "No watchdog file appeared, at a remote server execute the following:"
	echo "   while true; do ssh $HOSTNAME.root 'date +%s > /root/watchdog'; date; sleep 30; done"
	exit 9
fi

if [[ -e watchdog.reset ]] ; then 
	rm watchdog.reset
fi

crontab -l|grep "/root/bin/fw-failsafe.sh"
if [[ $? == 1 ]] ; then 
	# no crontab entry
	crontab -l | sed -e '$ a\
*/2 * * * * /root/bin/fw-failsafe.sh #Reset firewall in case of goof, enable this while testing.
' | crontab -
else
	# reset crontab
	crontab -l|sed 's_\(#\)\(.*/root/bin/fw-failsafe.sh.*\)_\2_' | crontab -
fi

echo "Firewall watchdog should now be running"
echo "  If watchdog file fails to be updated, the iptables will be reset"
