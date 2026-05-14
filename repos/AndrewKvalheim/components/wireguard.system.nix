{ config, lib, ... }:

let
  inherit (config) host;
  inherit (lib) mapAttrs' mapAttrsToList mkOption nameValuePair;
  inherit (lib.types) attrsOf int str submodule;
in
{
  options.host.wireguard = {
    ip = mkOption { type = str; };
    port = mkOption { type = int; };
    peers = mkOption {
      type = attrsOf (submodule {
        options = {
          ip = mkOption { type = str; };
          key = mkOption { type = str; };
          endpoint = mkOption { type = str; };
        };
      });
    };
  };

  config = {
    networking.wireguard = {
      enable = true;
      useNetworkd = true;

      interfaces.wg0 = {
        privateKeyFile = "/etc/secrets/wg0.key";
        ips = [ "${host.wireguard.ip}/24" ];
        peers = mapAttrsToList
          (_: peer: {
            allowedIPs = [ "${peer.ip}/32" ];
            endpoint = peer.endpoint;
            publicKey = peer.key;
          })
          host.wireguard.peers;
        dynamicEndpointRefreshSeconds = 3600;
      };
    };

    # Workaround for https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/6235
    networking.networkmanager.unmanaged = [ "wg0" ];

    networking.hosts = mapAttrs' (h: p: nameValuePair p.ip [ h ]) host.wireguard.peers;
  };
}
