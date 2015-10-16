#!/bin/bash
# script :  check_lefthand_cluster_vol.sh
# version : 1
# Comment : Script for Nagios to monitor the used volume space on a HP Lefthand Cluster
# Usage :   - command.cfg
#           $USER1$/check_lefthand_cluster_vol.sh -H $HOSTADDRESS$ $ARG1$ $ARG2$ $ARG3$ $ARG4$
#           - hostentry.cfg:
#           check_lefthand_cluster_vol.sh!-C <SNMP Community> -w 85 -c 95 -V Volumename exactly (Case sensitive)


if [ "$1" = "-H" ] && [ "$3" = "-C" ] && [ "$5" = "-w" ] && [ "$6" -gt "0" ] && [ "$7" = "-c" ] && [ "$8" -gt "$6" ] && [ "$9" = "-V" ]; then
  host="$2"
  community="$4"
  let beforewarn="$6"-1
  warn="$6"
  let beforecrit="$8"-1
  crit="$8"
  volname="${10}"
  hostnumber=`/usr/bin/snmpwalk -v 2c -c "$community" -m ALL "$host" 1.3.6.1.4.1.9804.3.1.1.2.12.97.1.2|grep $volname|awk {' print $1 '}|sed s/SNMPv2-SMI::enterprises.9804.3.1.1.2.12.97.1.2.//`
  volname=`/usr/lib64/nagios/plugins/check_snmp -H "$host" -C "$community" -P 2c -o 1.3.6.1.4.1.9804.3.1.1.2.12.97.1.2.$hostnumber | awk -F" " '{print $4}'`
  usedspace=`/usr/lib64/nagios/plugins/check_snmp -H "$host" -C "$community" -P 2c -o 1.3.6.1.4.1.9804.3.1.1.2.12.97.1.31.$hostnumber | awk -F" " '{print $4}'`
  totalspace=`/usr/lib64/nagios/plugins/check_snmp -H "$host" -C "$community" -P 2c -o 1.3.6.1.4.1.9804.3.1.1.2.12.97.1.5.$hostnumber | awk -F" " '{print $4}'`

  let percent="$totalspace"/100
let usedpercent="$usedspace"/$percent
let critval="$percent"*"$crit"/1024
let warnval="$percent"*"$warn"/1024
let usedmb="$usedspace"/1024
let totalmb="$totalspace"/1024
usedstr="MB"
PERF="$volname=$usedmb$usedstr;$warnval;$critval;0;$totalmb"
if [ $usedpercent -le $warn ]
then
        LINE="OK - $usedpercent % of volume $volname used."
        echo $LINE \| $PERF
        exit 0
elif [ $usedpercent -ge $warn -a $usedpercent -le $crit ]
then
        LINE="WARNING - $usedpercent % of volume $volname used."
        echo $LINE \| $PERF
        exit 1
elif  [ $usedpercent -ge $crit ]
then
        LINE="CRITICAL - $usedpercent % of volume $volname used."
        echo $LINE \| $PERF
        exit 2
fi


else
  echo "check_lefthand_cluster_vol.sh v1.0"
  echo ""
  echo "Usage:"
  echo "check_lefthand_cluster_vol.sh -H <hostIP> -C <SNMP Community> -w <warnlevel> -c <critlevel> -V Volumename exactly"
  echo ""
  echo "warnlevel and critlevel is percentage value without %"
  echo ""
  echo "2015 Jon Archer"
  exit
fi
