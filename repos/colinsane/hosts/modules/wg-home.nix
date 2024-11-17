# wireguard VPN which allows my devices to talk to eachother even when on physically different LANs
# for wireguard docs, see:
# - <https://nixos.wiki/wiki/WireGuard>
# - <https://wiki.archlinux.org/title/WireGuard>
{ config, lib, pkgs, ... }:

let
  cfg = config.sane.services.wg-home;
in
{
  options = with lib; {
    sane.services.wg-home.enable = mkEnableOption "wireguard VPN connecting my devices to eachother";
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
    sops.secrets."wg-home.priv".owner = "systemd-network";

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

    # TODO: networking.wireguard is deprecated; remove
    networking.wireguard = lib.mkIf (!cfg.routeThroughServo) {
      enable = true;
      interfaces.wg-home = {
        listenPort = 51820;
        privateKeyFile = "/run/secrets/wg-home.priv";

        ips = [
          "${cfg.ip}/24"
        ];

        peers = let
          all-peers = lib.mapAttrsToList (_: hostcfg: hostcfg.wg-home) config.sane.hosts.by-name;
          peer-list = builtins.filter (p: p.ip != null && p.ip != cfg.ip && p.pubkey != null) all-peers;
          # make separate peers to route each given host
        in
          builtins.map
            ({ ip, pubkey, endpoint }: assert endpoint == null; {
              publicKey = pubkey;
              allowedIPs = [
                (if builtins.match ".*/.*" ip != null then ip else "${ip}/32")
              ];
              # send keepalives every 25 seconds to keep NAT routes live.
              # only need to do this from client -> server though, i think.
              # persistentKeepalive = 25;
            })
            peer-list
        ;
      } // (lib.optionalAttrs cfg.forwardToWan {
        # documented here: <https://nixos.wiki/wiki/WireGuard#Server_setup_2>
        postSetup = ''
          ${lib.getExe' pkgs.iptables "iptables"} -t nat -A POSTROUTING --source ${cfg.ip}/24 ! --destination ${cfg.ip}/24 -j MASQUERADE
        '';
        postShutdown = ''
          ${lib.getExe' pkgs.iptables "iptables"} -t nat -D POSTROUTING --source ${cfg.ip}/24 ! --destination ${cfg.ip}/24 -j MASQUERADE
        '';
      });
    };

    # plug into my VPN abstractions so that one may:
    # - `sane-vpn up wg-home` to route all traffic through servo
    # - `sane-vpn do wg-home THING` to route select traffic through servo
    sane.vpn.wg-home = lib.mkIf cfg.routeThroughServo {
      id = 51;
      endpoint = config.sane.hosts.by-name."servo".wg-home.endpoint;
      keepalive = true;
      publicKey = config.sane.hosts.by-name."servo".wg-home.pubkey;
      addrV4 = cfg.ip;
      subnetV4 = "24";
      dns = [
        config.sane.hosts.by-name."servo".wg-home.ip
      ];
      privateKeyFile = "/run/secrets/wg-home.priv";
    };
  };
}
