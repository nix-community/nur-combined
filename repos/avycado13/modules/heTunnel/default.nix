{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.networking.heTunnel;
in
{
  options.networking.heTunnel = {
    enable = mkEnableOption "Hurricane Electric IPv6 tunnel broker (tunnelbroker.net)";

    tunnelId = mkOption {
      type = types.str;
      example = "123456";
      description = ''
        The numeric tunnel ID from the tunnelbroker.net dashboard.
        Used as the interface name suffix and for dynamic-IP updates.
      '';
    };

    serverIPv4 = mkOption {
      type = types.str;
      example = "216.66.80.30";
      description = "HE's IPv4 tunnel server endpoint address.";
    };

    clientIPv4 = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "203.0.113.5";
      description = ''
        This host's public IPv4 address, if static and known ahead of time.
        Leave null to let the kernel pick the outgoing interface's address
        automatically (works when there's no NAT between this host and HE).
      '';
    };

    clientIPv6 = mkOption {
      type = types.str;
      example = "2001:470:1f0e:1234::2";
      description = "Client IPv6 address of the tunnel's point-to-point link.";
    };

    routedPrefix = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "2001:470:1f0f:1234::";
      description = ''
        The routed /64 assigned for the LAN, if you requested one. Added as
        an address on the tunnel interface so it can be advertised/routed
        onward; leave null if you only need the point-to-point tunnel address.
      '';
    };

    dev = mkOption {
      type = types.str;
      default = "he-ipv6";
      description = "Name of the sit interface to create.";
    };

    ttl = mkOption {
      type = types.ints.unsigned;
      default = 255;
      description = "TTL for encapsulated packets sent over the tunnel.";
    };

    updateCredentialsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to a file (e.g. from sops-nix) containing
        `username:updateKey` used to keep the tunnel endpoint's IPv4 address
        current via HE's dynamic DNS-style update API. Required if
        `clientIPv4` is null and your public IP can change; leave null for a
        static IP where you never need to call the update endpoint.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.sits.${cfg.dev} = {
      remote = cfg.serverIPv4;
      local = mkIf (cfg.clientIPv4 != null) cfg.clientIPv4;
      inherit (cfg) ttl;
    };

    networking.interfaces.${cfg.dev}.ipv6.addresses = [
      {
        address = cfg.clientIPv6;
        prefixLength = 64;
      }
    ]
    ++ optional (cfg.routedPrefix != null) {
      address = cfg.routedPrefix;
      prefixLength = 64;
    };

    networking.defaultGateway6 = mkDefault {
      address = "::";
      interface = cfg.dev;
    };

    systemd.services.he-tunnel-update = mkIf (cfg.updateCredentialsFile != null) {
      description = "Update Hurricane Electric tunnel endpoint IPv4 address";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        DynamicUser = true;
        LoadCredential = "he-update:${cfg.updateCredentialsFile}";
        ExecStart = pkgs.writeShellScript "he-tunnel-update" ''
          set -euo pipefail
          creds="$(cat "$CREDENTIALS_DIRECTORY/he-update")"
          ${pkgs.curl}/bin/curl -fsS --user "$creds" \
            "https://ipv4.tunnelbroker.net/nic/update?hostname=${cfg.tunnelId}"
        '';
      };
      startAt = "*:0/15";
    };
  };
}
