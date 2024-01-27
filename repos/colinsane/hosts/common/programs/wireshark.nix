{ config, lib, ... }:
let
  cfg = config.sane.programs.wireshark;
in
{
  sane.programs.wireshark = {
    sandbox.method = "landlock";
    sandbox.extraPaths = [
      "/proc/net"  #< only needed if using landlock
    ];
    fs.".config/wireshark".dir = {};
    sandbox.extraConfig = [
      "--sane-sandbox-cap" "net_admin"
      "--sane-sandbox-cap" "net_raw"
    ];
    slowToBuild = true;
  };
}
