{ config, lib, ... }:
let
  cfg = config.sane.programs.wireshark;
in
{
  sane.programs.wireshark = {
    sandbox.method = "landlock";
    sandbox.autodetectCliPaths = "existingFile";  #< for loading pcap files on CLI
    sandbox.whitelistWayland = true;
    sandbox.net = "all";
    sandbox.capabilities = [ "net_admin" "net_raw" ];
    sandbox.extraPaths = [
      "/proc/net"  #< only needed if using landlock
    ];

    fs.".config/wireshark".dir = {};
    buildCost = 2;
  };
}
