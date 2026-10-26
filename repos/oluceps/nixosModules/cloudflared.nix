{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.cloudflared;
  proxyHardening = import ../lib/proxy-hardening.nix;
  resolverConfig = pkgs.writeText "cloudflared-resolver.conf" ''
    bind 127.0.0.55:53
    bind-tcp 127.0.0.55:53
    server 127.0.0.53
    server-https https://1.1.1.1/dns-query -group edge -exclude-default-group
    server-https https://1.0.0.1/dns-query -group edge -exclude-default-group
    nameserver /argotunnel.com/edge
    speed-check-mode none
    dualstack-ip-selection no
    max-reply-ip-num 16
    cache-persist no
    log-console yes
    log-level warn
    ca-file ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
  '';
  resolverFile = pkgs.writeText "cloudflared-resolv.conf" ''
    nameserver 127.0.0.55
    options edns0 timeout:10 attempts:2
  '';
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
in
{
  disabledModules = [ "services/networking/cloudflared.nix" ];
  options.services.cloudflared = {
    enable = mkEnableOption "Cloudflare Tunnel client daemon (formerly Argo Tunnel)";

    user = mkOption {
      type = types.str;
      default = "cloudflared";
      description = "User account under which Cloudflared runs.";
    };

    group = mkOption {
      type = types.str;
      default = "cloudflared";
      description = "Group under which cloudflared runs.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.cloudflared;
      defaultText = "pkgs.cloudflared";
      description = "The package to use for Cloudflared.";
    };

    edgeDnsOverHttps = mkEnableOption "a local HTTPS resolver for Cloudflare edge names";

    environmentFile = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.edgeDnsOverHttps || config.services.resolved.enable;
        message = "services.cloudflared.edgeDnsOverHttps requires systemd-resolved.";
      }
    ];
    systemd.services.cloudflared-resolver = mkIf cfg.edgeDnsOverHttps {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = proxyHardening // {
        ExecStart = "${pkgs.smartdns}/bin/smartdns -f -x -p - -c ${resolverConfig}";
        DynamicUser = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        Restart = "on-failure";
        RestartSec = "2s";
      };
    };
    systemd.services.cloudflared-tunnel = {
      after = [
        "network.target"
        "network-online.target"
      ]
      ++ lib.optional cfg.edgeDnsOverHttps "cloudflared-resolver.service";
      requires = lib.optional cfg.edgeDnsOverHttps "cloudflared-resolver.service";
      environment = lib.optionalAttrs cfg.edgeDnsOverHttps { GODEBUG = "netdns=go"; };
      wants = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = proxyHardening // {
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        CapabilityBoundingSet = [
          "CAP_NET_BIND_SERVICE"
          "CAP_NET_RAW"
        ];
        BindReadOnlyPaths = lib.optional cfg.edgeDnsOverHttps "${resolverFile}:/etc/resolv.conf";
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${cfg.package}/bin/cloudflared --no-autoupdate tunnel run --token $TOKEN";
        Restart = "on-failure";
      };
    };

    users.users = mkIf (cfg.user == "cloudflared") {
      cloudflared = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "cloudflared") { cloudflared = { }; };
  };
}
