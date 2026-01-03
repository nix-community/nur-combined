{ lib, config, ... }:
let
  interface_conf = {
    useDHCP = true;
    ipv4.addresses = [
      {
        address = "10.46.0.7";
        prefixLength = 24;
      }
    ];
    ipv4.routes = [
      {
        address = "0.0.0.0";
        prefixLength = 0;
        via = "10.46.0.1";
        options.scope = "global";
        options.src = "10.46.0.7";
        options.metric = "1200";
      }
    ];
  };
in
{
  networking.interfaces."ens3" = lib.mkIf (!config.vacu.underTest) interface_conf;
  networking.interfaces."eth0" = lib.mkIf (config.vacu.underTest) interface_conf;
}
