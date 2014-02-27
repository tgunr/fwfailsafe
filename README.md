fwfailsafe
==========

Firewall failsafe watchdog for iptables.

## Firewall Change Procedure

Before executing any change to the firewall policy you should use the procedures outlined here to startup a watchdog task which will reset the firewall in case of lockout. All firewall policies are disabled and the firewall will permit access from any host on all chains.

## Watchdog Overview

The watchdog task consists of two parts, a server side task which monitors changes to a file made by the client and a client side task which periodically updates a file on the server side.

First, setup the client side task as outlined before invoking the server side. If you try to setup the server side first you run the risk of premature detection of failure which will disable the entire firewall.

### Client Side Task

The client side is fairly simple, increment a number and write it to a file on the server periodically. The example presumes you have the proper ssh keys setup to permit access to the server.

    while true; do ssh $SERVER 'date +%s > /root/watchdog'; date; sleep 30; done

To stop the client task, simply hit CTRL-C.

### Server Side Task

On the server side, install the files from the repository into _/root/bin/_ folder then execute
    
    /root/bin/fwfailsafe start

The script will install a cron job that check if the date is being incremented in the watchdog file. If the date stops being incremented for whatever reason the firewall tables will be reset.

To stop the task:

    /root/bin/fwfailsafe stop

