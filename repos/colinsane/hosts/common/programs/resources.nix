{ ... }:
{
  sane.programs.resources = {
    sandbox.keepPidsAndProc = true;
    sandbox.whitelistWayland = true;
    # sandbox.net = "all";

    sandbox.extraHomePaths = [
      ".local/share/applications"  # so it can map process to app name
    ];
    sandbox.extraPaths = [
      "/sys/class/hwmon"
      "/sys/class/net"
      "/sys/devices"
    ];
  };
}
