# HP Lefthand Volume check plugin for Nagios
This bash script will run several snmp queries against given clusters to report on volume sizes.

# How to use

Say we have a Volume named VOL1 can monitor a volume using the following command

`./check_lefthand_cluster_vol.sh -H 10.1.0.50 -C public -w 80 -c 95 -V VOL1`

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
  check_command  check_lefthand_cluster_vol.sh! -C public  -w 80 -c 90 -V VOL1

  } 
  ```
This plugin also outputs performance data from the check, useful for pnp4nagios or similar data collection.
