{ config, lib, pkgs, ... }:

let
  inherit (builtins) filter map;
  inherit (lib) concatMap mapAttrsToList mkIf mkMerge mkOption optionalAttrs types;
  cfg = config.sane.services.wg-home;
  server-cfg = config.sane.hosts.by-name."servo".wg-home;
  mkPeer = { ips, pubkey, endpoint }: {
    publicKey = pubkey;
    allowedIPs = map (k: "${k}/32") ips;
  } // (optionalAttrs (endpoint != null) {
    inherit endpoint;
    # send keepalives every 25 seconds to keep NAT routes live.
    # only need to do this from client -> server though, i think.
    persistentKeepalive = 25;
    # allows wireguard to notice DNS/hostname changes, with this much effective TTL.
    dynamicEndpointRefreshSeconds = 600;
  });
  # make separate peers to route each given host
  mkClientPeers = hosts: map (p: mkPeer {
    inherit (p) pubkey endpoint;
    ips = [ p.ip ];
  }) hosts;
  # make a single peer which routes all the given hosts
  mkServerPeer = hosts: mkPeer {
    inherit (server-cfg) pubkey endpoint;
    ips = map (h: h.ip) hosts;
  };
in
{
  options = {
    sane.services.wg-home.enable = mkOption {
      type = types.bool;
      default = false;
    };
    sane.services.wg-home.ip = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # generate a (deterministic) wireguard private key
    sane.derived-secrets."/run/wg-home.priv" = {
      len = 32;
      encoding = "base64";
    };

    # wireguard VPN which allows everything on my domain to speak to each other even when
    # not behind a shared LAN.
    # this config defines both the endpoint (server) and client configs

    # for convenience, have both the server and client use the same port for their wireguard connections.
    networking.firewall.allowedUDPPorts = [ 51820 ];
    networking.wireguard.interfaces.wg-home = {
      listenPort = 51820;
      privateKeyFile = "/run/wg-home.priv";
      preSetup =
        let
          gen-key = config.sane.fs."/run/wg-home.priv".unit;
        in
          "${pkgs.systemd}/bin/systemctl start '${gen-key}'";

      ips = [
        "${cfg.ip}/24"
      ];

      peers =
        let
          all-peers = mapAttrsToList (_: hostcfg: hostcfg.wg-home) config.sane.hosts.by-name;
          peer-list = filter (p: p.ip != null && p.ip != cfg.ip && p.pubkey != null) all-peers;
        in
          if cfg.ip == server-cfg.ip then
            # if we're the server, then we maintain the entire client list
            mkClientPeers peer-list
          else
            # but if we're a client, we maintain a single peer -- the server -- which does the actual routing
            [ (mkServerPeer peer-list) ];
    };
  };
}
