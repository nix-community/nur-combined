{ lib, config, ... }:
let
  # from `curl -fsSL http://169.254.169.254/metadata/v1.json | jq '.interfaces.public[0].anchor_ipv4'`
  # {
  #   "ip_address": "10.46.0.7",
  #   "netmask": "255.255.0.0",
  #   "gateway": "10.46.0.1"
  # }
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
