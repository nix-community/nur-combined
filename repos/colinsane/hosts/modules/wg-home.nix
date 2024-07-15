# wireguard VPN which allows my devices to talk to eachother even when on physically different LANs
# for wireguard docs, see:
# - <https://nixos.wiki/wiki/WireGuard>
# - <https://wiki.archlinux.org/title/WireGuard>
{ config, lib, pkgs, ... }:

let
  cfg = config.sane.services.wg-home;
  mkPeer = { ips, pubkey, endpoint }: {
    publicKey = pubkey;
    allowedIPs = builtins.map (k: if builtins.match ".*/.*" k != null then k else "${k}/32") ips;
  } // (lib.optionalAttrs (endpoint != null) {
    inherit endpoint;
    # send keepalives every 25 seconds to keep NAT routes live.
    # only need to do this from client -> server though, i think.
    persistentKeepalive = 25;
    # allows wireguard to notice DNS/hostname changes, with this much effective TTL.
    dynamicEndpointRefreshSeconds = 600;
    # the refresh fails (because e.g. DNS fails to resolve), try it again this soon instead.
    # defaults to the same as dynamicEndpointRefreshSeconds, but i think setting it that high stalls my nix switches!
    dynamicEndpointRefreshRestartSeconds = 10;
  });
  # make separate peers to route each given host
  mkClientPeers = hosts: builtins.map (p: mkPeer {
    inherit (p) pubkey endpoint;
    ips = [ p.ip ];
  }) hosts;
in
{
  options = with lib; {
    sane.services.wg-home.enable = mkOption {
      type = types.bool;
      default = false;
    };
    sane.services.wg-home.visibleToWan = mkOption {
      type = types.bool;
      default = false;
      description = "whether to make this port visible on the WAN";
    };
    sane.services.wg-home.forwardToWan = mkOption {
      type = types.bool;
      default = false;
      description = ''
        whether to forward packets from wireguard clients to the WAN,
        i.e. whether to act as a VPN exit node.
      '';
    };
    sane.services.wg-home.routeThroughServo = mkOption {
      type = types.bool;
      default = true;
      description = ''
        whether to contact peers by routing through a stationary server.
        should be true for all "clients", and false for that stationary server.
      '';
    };
    sane.services.wg-home.ip = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    # generate a (deterministic) wireguard private key
    sane.derived-secrets."/run/wg-home.priv" = {
      len = 32;
      encoding = "base64";
      acl.mode = "0640";
      acl.group = "systemd-network";
    };

    # wireguard VPN which allows everything on my domain to speak to each other even when
    # not behind a shared LAN.
    # also allows clients to proxy WAN traffic through it.
    # this config defines both the endpoint (server) and client configs.

    sane.ports.ports."51820" = lib.mkIf (!cfg.routeThroughServo) {
      protocol = [ "udp" ];
      visibleTo.lan = true;
      visibleTo.wan = cfg.visibleToWan;
      visibleTo.doof = cfg.visibleToWan;
      description = "colin-wireguard";
    };

    networking.wireguard.interfaces.wg-home = lib.mkIf (!cfg.routeThroughServo) ({
      listenPort = 51820;
      privateKeyFile = "/run/wg-home.priv";
      # TODO: make this `wants` and `after`, instead of manually starting it
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
          all-peers = lib.mapAttrsToList (_: hostcfg: hostcfg.wg-home) config.sane.hosts.by-name;
          peer-list = builtins.filter (p: p.ip != null && p.ip != cfg.ip && p.pubkey != null) all-peers;
        in
          mkClientPeers peer-list
      ;
    } // (lib.optionalAttrs cfg.forwardToWan {
      # documented here: <https://nixos.wiki/wiki/WireGuard#Server_setup_2>
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING --source ${cfg.ip}/24 ! --destination ${cfg.ip}/24 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING --source ${cfg.ip}/24 ! --destination ${cfg.ip}/24 -j MASQUERADE
      '';
    }));

    # plug into my VPN abstractions so that one may:
    # - `sane-vpn up wg-home` to route all traffic through servo
    # - `sane-vpn do wg-home THING` to route select traffic through servo
    sane.vpn.wg-home = lib.mkIf cfg.routeThroughServo {
      id = 51;
      endpoint = config.sane.hosts.by-name."servo".wg-home.endpoint;
      publicKey = config.sane.hosts.by-name."servo".wg-home.pubkey;
      addrV4 = cfg.ip;
      subnetV4 = "24";
      dns = [
        config.sane.hosts.by-name."servo".wg-home.ip
      ];
      privateKeyFile = "/run/wg-home.priv";
    };
  };
}
