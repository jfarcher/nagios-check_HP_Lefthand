# HP Lefthand Volume check plugin for Nagios
This bash script will run several snmp queries against given clusters to report on volume sizes.

# How to use

Say we have a Volume named VOL1 we can monitor the volume using the following command

`./check_lefthand_cluster_vol.sh -H 10.1.0.50 -C public -w 80 -c 95 -V VOL1`

Switches:

-H Hostname or IP address of cluster VIP

-C SNMP Community string (only v2c supported at this point)

-w Warning Value

-c Critical Value

-V Volume name exactly as it is in CMC

This check would then return something like

`OK - 12 % of volume "VOL1" used. | "VOL1"=252213MB;1677721;1887436;0;2097152`

Adding this into Nagios would be a case of:

copy the check_lefthand_cluster_vol.sh file to /usr/lib64/nagios/plugins or /usr/lib/nagios/plugins, whichever is relevant to your nagios installation. 

make sure the file is executable

chmod +x /usr/lib64/nagios/plugins/check_lefthand_cluster_vol.sh

or

chmod +x /usr/lib/nagios/plugins/check_lefthand_cluster_vol.sh

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
  check_command  check_lefthand_cluster_vol.sh! -C public  -w 80 -c 90 -V VOL1

  } 
  ```
This plugin also outputs performance data from the check, useful for pnp4nagios or similar data collection.
