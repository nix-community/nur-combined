# A simple, in-kernel VPN service
#
# Strongly inspired by [1].
# [1]: https://github.com/delroth/infra.delroth.net/blob/master/roles/wireguard-peer.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.wireguard;
  hostName = config.networking.hostName;

  peers = config.my.secrets.wireguard.peers;
  thisPeer = peers."${hostName}";
  thisPeerIsServer = thisPeer ? externalIp;
  # Only connect to clients from server, and only connect to server from clients
  otherPeers =
    let
      allOthers = lib.filterAttrs (name: _: name != hostName) peers;
      shouldConnectToPeer = _: peer: thisPeerIsServer != (peer ? externalIp);
    in
    lib.filterAttrs shouldConnectToPeer allOthers;

  extIface = config.my.networking.externalInterface;
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
  };

  config.networking = lib.mkIf cfg.enable {
    wg-quick.interfaces."${cfg.iface}" = {
      listenPort = cfg.port;
      address = with cfg.net; with lib; [
        "${v4.subnet}.${toString thisPeer.clientNum}/${toString v4.mask}"
        "${v6.subnet}::${toString thisPeer.clientNum}/${toHexString v6.mask}"
      ];
      # Insecure, I don't care
      privateKey = thisPeer.privateKey;

      peers = lib.mapAttrsToList
        (_: peer: {
          inherit (peer) publicKey;
        } // lib.optionalAttrs thisPeerIsServer {
          # Only forward from server to clients
          allowedIPs = with cfg.net; [
            "${v4.subnet}.${toString peer.clientNum}/32"
            "${v6.subnet}::${toString peer.clientNum}/128"
          ];
        } // lib.optionalAttrs (peer ? externalIp) {
          # Known addresses
          endpoint = "${peer.externalIp}:${toString cfg.port}";
        } // lib.optionalAttrs (!thisPeerIsServer) {
          # Forward all traffic to server
          allowedIPs = with cfg.net; [
            "0.0.0.0/0"
            "::/0"
          ];
          # Roaming clients need to keep NAT-ing active
          persistentKeepalive = 10;
        })
        otherPeers;
    } // lib.optionalAttrs thisPeerIsServer {
      # Setup forwarding on server
      postUp = with cfg.net; ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i ${cfg.iface} -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${v4.subnet}.1/${toString v4.mask} -o ${extIface} -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i ${cfg.iface} -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s ${v6.subnet}::1/${toString v6.mask} -o ${extIface} -j MASQUERADE
      '';
      preDown = with cfg.net; ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i ${cfg.iface} -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${v4.subnet}.1/${toString v4.mask} -o ${extIface} -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i ${cfg.iface} -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s ${v6.subnet}::1/${toString v6.mask} -o ${extIface} -j MASQUERADE
      '';
    } // lib.optionalAttrs (!thisPeerIsServer) {
      # Use DNS servers hosted on wireguard servers
      dns =
        let
          isServer = _: peer: peer ? externalIp;
          toInternalIps = peer: [
            "${cfg.net.v4.subnet}.${toString peer.clientNum}"
            "${cfg.net.v6.subnet}::${toString peer.clientNum}"
          ];
          servers = lib.filterAttrs isServer otherPeers;
          internalIps = lib.flatten
            (lib.mapAttrsToList (_: peer: toInternalIps peer) servers);
          internalServers = lib.optionals cfg.dns.useInternal internalIps;
        in
        internalServers ++ cfg.dns.additionalServers;
    };

    nat = lib.optionalAttrs thisPeerIsServer {
      enable = true;
      externalInterface = extIface;
      internalInterfaces = [ cfg.iface ];
    };

    firewall.allowedUDPPorts = [ cfg.port ];
  };

  # Do not start the service by making it not wanted by any unit
  config.systemd.services.wg-quick-wg = lib.mkIf (!cfg.startAtBoot) {
    wantedBy = lib.mkForce [ ];
  };
}
