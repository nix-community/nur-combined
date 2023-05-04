{ config, lib, ... }:

{
  # give each host a shortname that all the other hosts know, to allow easy comms.
  networking.hosts = lib.mkMerge [
    (lib.mapAttrs' (host: cfg: {
      # bare-name for LAN addresses
      # if using router's DNS, these mappings will already exist.
      # if using a different DNS provider (which servo does), then we need to explicity provide them.
      # ugly hack. would be better to get servo to somehow use the router's DNS
      name = cfg.lan-ip;
      value = [ host ];
    }) config.sane.hosts.by-name)
    (lib.mapAttrs' (host: cfg: {
      # -hn suffixed name for communication over my wg-home VPN.
      # hn = "home network"
      name = cfg.wg-home.ip;
      value = [ "${host}-hn" ];
    }) config.sane.hosts.by-name)
  ];
}
