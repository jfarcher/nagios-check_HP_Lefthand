# HP Lefthand Volume check plugin for Nagios
This bash script will run several snmp queries against given clusters to report on volume sizes.

# How to use
Using the following snmpwalk query the object ID can be gained for each volume:

`snmpwalk  -v 2c -c <SNMP Community> -m ALL <IPADDRESS> 1.3.6.1.4.1.9804.3.1.1.2.12.97.1.2`

By replacing the IPADDRESS with the VIP of your cluster manager and using your SNMP community string, this query will return a list of volumes in the management group.

Part of the returned data will be the OID above with an additional element on the end. Using this additional element when calling the check script we can return data on that particular volume.

For example:

`snmpwalk -v 2c -c public -m ALL 10.1.0.50 1.3.6.1.4.1.9804.3.1.1.2.12.97.1.2`

May return the following volume data:

`SNMPv2-SMI::enterprises.9804.3.1.1.2.12.97.1.2.1 = STRING: "VOL1"`

We can monitor that volume using the following command

`./check_lefthand_cluster_vol.sh -H 10.1.0.50 -C public -w 80 -c 95 -O 1`

This check would then return something like

`OK - 12 % of volume "VOL1" used. | "VOL1"=252213MB;1677721;1887436;0;2097152`

Adding this into Nagios would be a case of:

Adding the following to commands.cfg

```
define command{
        command_name    check_lefthand_cluster_vol.sh
        command_line    $USER1$/check_lefthand_cluster_vol.sh -H $HOSTADDRESS$ $ARG1$ $ARG2$ $ARG3$ $ARG4$
  }
  ```

Adding the following to your host entry

``` 
  define service{
  use generic-service
  host_name 10.1.0.50
  service_description VOL1 Size
  check_command  check_lefthand_cluster_vol.sh! -C public  -w 80 -c 90 -O 1

  } 
  ```

