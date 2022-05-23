# A simple, in-kernel VPN service
#
# Strongly inspired by [1].
# [1]: https://github.com/delroth/infra.delroth.net/blob/master/roles/wireguard-peer.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.wireguard;
  secrets = config.age.secrets;
  hostName = config.networking.hostName;

  peers =
    let
      mkPeer = name: attrs: {
        inherit (attrs) clientNum publicKey;
        privateKeyFile = secrets."wireguard/${name}/private-key".path;
      } // lib.optionalAttrs (attrs ? externalIp) {
        inherit (attrs) externalIp;
      };
    in
    lib.mapAttrs mkPeer {
      # "Server"
      porthos = {
        clientNum = 1;
        publicKey = "PLdgsizztddri0LYtjuNHr5r2E8D+yI+gM8cm5WDfHQ=";
        externalIp = "91.121.177.163";
      };

      # "Clients"
      aramis = {
        clientNum = 2;
        publicKey = "QJSWIBS1mXTpxYybLlKu/Y5wy0GFbUfn4yPzpF1DZDc=";
      };

      richelieu = {
        clientNum = 3;
        publicKey = "w4IADAj2Tt7Qe95a0RxDv9ovg/Dr/f3q1LrVOPF48Rk=";
      };

      # Sarah's iPhone
      milady = {
        clientNum = 4;
        publicKey = "3MKEu4F6o8kww54xeAao5Uet86fv8z/QsZ2L2mOzqDQ=";
      };
    };
  thisPeer = peers."${hostName}";
  thisPeerIsServer = thisPeer ? externalIp;
  # Only connect to clients from server, and only connect to server from clients
  otherPeers =
    let
      allOthers = lib.filterAttrs (name: _: name != hostName) peers;
      shouldConnectToPeer = _: peer: thisPeerIsServer != (peer ? externalIp);
    in
    lib.filterAttrs shouldConnectToPeer allOthers;

  extIface = config.my.hardware.networking.externalInterface;

  mkInterface = clientAllowedIPs: {
    listenPort = cfg.port;
    address = with cfg.net; with lib; [
      "${v4.subnet}.${toString thisPeer.clientNum}/${toString v4.mask}"
      "${v6.subnet}::${toString thisPeer.clientNum}/${toHexString v6.mask}"
    ];
    inherit (thisPeer) privateKeyFile;

    peers =
      let
        mkPeer = _: peer: lib.mkMerge [
          {
            inherit (peer) publicKey;
          }

          (lib.optionalAttrs thisPeerIsServer {
            # Only forward from server to clients
            allowedIPs = with cfg.net; [
              "${v4.subnet}.${toString peer.clientNum}/32"
              "${v6.subnet}::${toString peer.clientNum}/128"
            ];
          })

          (lib.optionalAttrs (!thisPeerIsServer) {
            # Forward all traffic through wireguard to server
            allowedIPs = clientAllowedIPs;
            # Roaming clients need to keep NAT-ing active
            persistentKeepalive = 10;
            # We know that `peer` is a server, set up the endpoint
            endpoint = "${peer.externalIp}:${toString cfg.port}";
          })
        ];
      in
      lib.mapAttrsToList mkPeer otherPeers;

    # Set up clients to use configured DNS servers
    dns =
      let
        toInternalIps = peer: [
          "${cfg.net.v4.subnet}.${toString peer.clientNum}"
          "${cfg.net.v6.subnet}::${toString peer.clientNum}"
        ];
        # We know that `otherPeers` is an attribute set of servers
        internalIps = lib.flatten
          (lib.mapAttrsToList (_: peer: toInternalIps peer) otherPeers);
        internalServers = lib.optionals cfg.dns.useInternal internalIps;
      in
      lib.mkIf (!thisPeerIsServer)
        (internalServers ++ cfg.dns.additionalServers);
  };
in
{
  options.my.services.wireguard = with lib; {
    enable = mkEnableOption "Wireguard VPN service";

    startAtBoot = mkEnableOption ''
      Should the VPN service be started at boot. Must be true for the server to
      work reliably.
    '';

    iface = mkOption {
      type = types.str;
      default = "wg";
      example = "wg0";
      description = "Name of the interface to configure";
    };

    port = mkOption {
      type = types.port;
      default = 51820;
      example = 55555;
      description = "Port to configure for Wireguard";
    };

    dns = {
      useInternal = my.mkDisableOption ''
        Use internal DNS servers from wireguard 'server'
      '';

      additionalServers = mkOption {
        type = with types; listOf str;
        default = [
          "1.0.0.1"
          "1.1.1.1"
        ];
        example = [
          "8.8.4.4"
          "8.8.8.8"
        ];
        description = "Which DNS servers to use in addition to adblock ones";
      };
    };

    net = {
      # FIXME: use new ip library to handle this more cleanly
      v4 = {
        subnet = mkOption {
          type = types.str;
          default = "10.0.0";
          example = "10.100.0";
          description = "Which prefix to use for internal IPs";
        };
        mask = mkOption {
          type = types.int;
          default = 24;
          example = 28;
          description = "The CIDR mask to use on internal IPs";
        };
      };
      # FIXME: extend library for IPv6
      v6 = {
        subnet = mkOption {
          type = types.str;
          default = "fd42:42:42";
          example = "fdc9:281f:04d7:9ee9";
          description = "Which prefix to use for internal IPs";
        };
        mask = mkOption {
          type = types.int;
          default = 64;
          example = 68;
          description = "The CIDR mask to use on internal IPs";
        };
      };
    };

    internal = {
      enable = mkEnableOption ''
        Additional interface which does not route WAN traffic, but gives access
        to wireguard peers.
        Is useful for accessing DNS and other internal services, without having
        to route all traffic through wireguard.
        Is automatically disabled on server, and enabled otherwise.
      '' // {
        default = !thisPeerIsServer;
      };

      name = mkOption {
        type = types.str;
        default = "lan";
        example = "internal";
        description = "Which name to use for this interface";
      };

      startAtBoot = my.mkDisableOption ''
        Should the internal VPN service be started at boot.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Normal interface should route all traffic from client through server
    {
      networking.wg-quick.interfaces."${cfg.iface}" = mkInterface [
        "0.0.0.0/0"
        "::/0"
      ];
    }

    # Additional inteface is only used to get access to "LAN" from wireguard
    (lib.mkIf cfg.internal.enable {
      networking.wg-quick.interfaces."${cfg.internal.name}" = mkInterface [
        "${cfg.net.v4.subnet}.0/${toString cfg.net.v4.mask}"
        "${cfg.net.v6.subnet}::/${toString cfg.net.v6.mask}"
      ];
    })

    # Expose port
    {
      networking.firewall.allowedUDPPorts = [ cfg.port ];
    }

    # Allow NATing wireguard traffic on server
    (lib.mkIf thisPeerIsServer {
      networking.nat = {
        enable = true;
        externalInterface = extIface;
        internalInterfaces = [ cfg.iface ];
      };
    })

    # Set up forwarding to WAN
    (lib.mkIf thisPeerIsServer {
      networking.wg-quick.interfaces."${cfg.iface}" = {
        postUp = with cfg.net; ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i ${cfg.iface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING \
              -s ${v4.subnet}.${toString thisPeer.clientNum}/${toString v4.mask} \
              -o ${extIface} -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -A FORWARD -i ${cfg.iface} -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING \
              -s ${v6.subnet}::${toString thisPeer.clientNum}/${toString v6.mask} \
              -o ${extIface} -j MASQUERADE
        '';
        preDown = with cfg.net; ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i ${cfg.iface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING \
              -s ${v4.subnet}.${toString thisPeer.clientNum}/${toString v4.mask} \
              -o ${extIface} -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -D FORWARD -i ${cfg.iface} -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING \
              -s ${v6.subnet}::${toString thisPeer.clientNum}/${toString v6.mask} \
              -o ${extIface} -j MASQUERADE
        '';
      };
    })

    # When not needed at boot, ensure that there are no reverse dependencies
    (lib.mkIf (!cfg.startAtBoot) {
      systemd.services."wg-quick-${cfg.iface}".wantedBy = lib.mkForce [ ];
    })

    # Same idea, for internal-only interface
    (lib.mkIf (cfg.internal.enable && !cfg.internal.startAtBoot) {
      systemd.services."wg-quick-${cfg.internal.name}".wantedBy = lib.mkForce [ ];
    })
  ]);
}
