{ inputs, ... }:

let
  inherit (inputs) self;
  system-lib = import "${self}/system/lib" { inherit inputs; };
  inherit (system-lib) obtainIPV4Address;
  ips = {
    grimsnes = obtainIPV4Address "grimsnes" "brume";
    surtsey = obtainIPV4Address "surtsey" "brume";
    holuhraun = obtainIPV4Address "holuhraun" "brume";
    eyjafjallajokull = obtainIPV4Address "eyjafjallajokull" "brume";
  };

in {
  networking = {
    hosts = {
      "${ips.grimsnes}" = [ "grimsnes" ];
      "${ips.surtsey}" = [ "surtsey" ];
      "${ips.holuhraun}" = [ "holuhraun" ];
      "${ips.eyjafjallajokull}" = [ "eyjafjallajokull" ];
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
