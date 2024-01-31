{ config, lib, ... }:
let
  cfg = config.sane.programs.wireshark;
in
{
  sane.programs.wireshark = {
    sandbox.method = "landlock";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.extraPaths = [
      "/proc/net"  #< only needed if using landlock
    ];
    fs.".config/wireshark".dir = {};
    sandbox.capabilities = [ "net_admin" "net_raw" ];
    slowToBuild = true;
  };
}
