{ inputs, ... }:

let
  inherit (inputs) self;
  system-lib = import "${self}/system/lib" { inherit inputs; };
  inherit (system-lib) obtainIPV4Address;
  ips = {
    grimsnes = obtainIPV4Address "grimsnes" "vestfirdir";
    surtsey = obtainIPV4Address "surtsey" "vestfirdir";
    holuhraun = obtainIPV4Address "holuhraun" "vestfirdir";
    eyjafjallajokull = obtainIPV4Address "eyjafjallajokull" "vestfirdir";
    torfajokull = obtainIPV4Address "torfajokull" "vestfirdir";
  };

in {
  networking = {
    hosts = {
      "${ips.grimsnes}" = [ "grimsnes" ];
      "${ips.surtsey}" = [ "surtsey" ];
      "${ips.holuhraun}" = [ "holuhraun" ];
      "${ips.eyjafjallajokull}" = [ "eyjafjallajokull" ];
      "${ips.torfajokull}" = [ "torfajokull" ];
    };
    firewall = {
      enable = false;
      allowedTCPPorts = [
        23561 # F;sskjfd
      ];
      allowedUDPPorts = [ ];
    };
    networkmanager.enable = true;
  };
  users.extraGroups.networkmanager.members = [ "bjorn" ];
}
