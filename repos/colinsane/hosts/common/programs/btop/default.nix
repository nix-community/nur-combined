{ ... }:
{
  sane.programs.btop = {
    sandbox.keepPidsAndProc = true;
    sandbox.tryKeepUsers = true;
    sandbox.extraPaths = [
      "/sys/class/net"
      "/sys/devices"
    ];
    sandbox.net = "all";  # otherwise it can't show net stats
  };
}
