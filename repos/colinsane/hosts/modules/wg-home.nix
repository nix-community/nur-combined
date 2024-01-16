# wireguard VPN which allows my devices to talk to eachother even when on physically different LANs
# for wireguard docs, see:
# - <https://nixos.wiki/wiki/WireGuard>
# - <https://wiki.archlinux.org/title/WireGuard>
{ config, lib, pkgs, ... }:

let
  cfg = config.sane.services.wg-home;
  server-cfg = config.sane.hosts.by-name."servo".wg-home;
  mkPeer = { ips, pubkey, endpoint }: {
    publicKey = pubkey;
    allowedIPs = builtins.map (k: "${k}/32") ips;
  } // (lib.optionalAttrs (endpoint != null) {
    inherit endpoint;
    # send keepalives every 25 seconds to keep NAT routes live.
    # only need to do this from client -> server though, i think.
    persistentKeepalive = 25;
    # allows wireguard to notice DNS/hostname changes, with this much effective TTL.
    dynamicEndpointRefreshSeconds = 600;
  });
  # make separate peers to route each given host
  mkClientPeers = hosts: builtins.map (p: mkPeer {
    inherit (p) pubkey endpoint;
    ips = [ p.ip ];
  }) hosts;
  # make a single peer which routes all the given hosts
  mkServerPeer = hosts: mkPeer {
    inherit (server-cfg) pubkey endpoint;
    ips = builtins.map (h: h.ip) hosts;
  };
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
    };

    # wireguard VPN which allows everything on my domain to speak to each other even when
    # not behind a shared LAN.
    # this config defines both the endpoint (server) and client configs

    # for convenience, have both the server and client use the same port for their wireguard connections.
    sane.ports.ports."51820" = {
      protocol = [ "udp" ];
      visibleTo.lan = true;
      visibleTo.wan = cfg.visibleToWan;
      description = "colin-wireguard";
    };

    networking.wireguard.interfaces.wg-home = lib.mkMerge [
      {
        listenPort = 51820;
        privateKeyFile = "/run/wg-home.priv";
        # TODO: this make this `wants` and `after`, instead of manually starting it
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
            if cfg.routeThroughServo then
              # if acting as a client, then maintain a single peer -- the server -- which does the actual routing
              [ (mkServerPeer peer-list) ]
            else
              # if acting as a server, route to each peer individually
              mkClientPeers peer-list
        ;
      }
      (lib.mkIf cfg.forwardToWan {
        # documented here: <https://nixos.wiki/wiki/WireGuard#Server_setup_2>
        # TODO: don't hardcode eth0!
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${cfg.ip}/24 -o eth0 -j MASQUERADE
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${cfg.ip}/24 -o eth0 -j MASQUERADE
        '';
      })
    ];

    # also expose a wg-quick interface, so that one may `sane-vpn up servo` to route all traffic through servo
    networking.wg-quick.interfaces.vpn-servo = {
      address = [ cfg.ip ];
      dns = [
        config.sane.hosts.by-name."servo".wg-home.ip
      ];
      privateKeyFile = "/run/wg-home.priv";

      peers = [
        {
          endpoint = config.sane.hosts.by-name."servo".wg-home.endpoint;
          publicKey = config.sane.hosts.by-name."servo".wg-home.pubkey;
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
        }
      ];
      # to start: `systemctl start wg-quick-${name}`
      autostart = false;

      # wg-home and vpn-servo interfaces interfere with the result that when connected to both,
      # other wg-home users (lappy-hn, ...) aren't visible. disabling wg-home while the full
      # vpn-servo is active allows wg-home users to be reachable again
      preUp = "${pkgs.iproute2}/bin/ip link set wg-home down";
      postDown = "${pkgs.iproute2}/bin/ip link set wg-home up";
    };
  };
}
