# TODO: wrap with password.
# usage:
# - reboot BMC: `ipmitool -I lanplus -H 10.78.78.72 -U admin -P $IPMI_PASSWORD mc reset cold`
{ ... }:
{
  sane.programs.ipmitool = {
    sandbox.method = null;  #< TODO: sandbox
  };
}
