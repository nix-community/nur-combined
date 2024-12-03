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
    systemd.network = {
      enable = true;
      netdevs."90-wg0" = {
        netdevConfig = { Name = "wg0"; Kind = "wireguard"; };
        wireguardConfig.PrivateKeyFile = "/var/lib/wireguard/wg0.key";
        wireguardPeers = mapAttrsToList
          (_: peer: {
            AllowedIPs = [ "${peer.ip}/32" ];
            Endpoint = peer.endpoint;
            PublicKey = peer.key;
          })
          host.wireguard.peers;
      };
      networks."90-wg0" = { name = "wg0"; address = [ "${host.wireguard.ip}/24" ]; };
    };

    # Workaround for https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/6235
    networking.networkmanager.unmanaged = [ "wg0" ];

    networking.hosts = mapAttrs' (h: p: nameValuePair p.ip [ h ]) host.wireguard.peers;
  };
}
