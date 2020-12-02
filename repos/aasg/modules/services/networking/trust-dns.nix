{ config, lib, pkgs, ... }:
with lib;
let
  format = pkgs.formats.toml { };
  cfg = config.services.trust-dns;
  configFile = format.generate "named.toml" cfg.settings;
in
{
  options = {
    services.trust-dns = {
      enable = mkEnableOption "Trust-DNS authoritative server";

      package = mkOption {
        type = types.package;
        default = pkgs.trust-dns;
        defaultText = "pkgs.trust-dns";
        description = "Trust-DNS package to use.";
      };

      settings = mkOption {
        type = format.type;
        default = { };
        description = "Additional Trust-DNS settings.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.trust-dns.settings = {
      directory = "/var/lib/trust-dns";
    };

    environment.systemPackages = [ cfg.package ];

    systemd.services.trust-dns = {
      description = "Trust-DNS authoritative server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/named --quiet --config=${configFile}";
        DynamicUser = true;
        ConfigurationDirectory = "trust-dns";
        StateDirectory = "trust-dns";
        Restart = "on-abnormal";
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        NoNewPrivileges = true;
        PrivateDevices = true;
      };
    };
  };
}
