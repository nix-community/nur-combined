{ ... }:
{
  sane.programs.sane-sysload = {
    sandbox.method = "bwrap";
    sandbox.extraPaths = [
      "/sys/class/power_supply"
      "/sys/devices"
    ];
  };
}
