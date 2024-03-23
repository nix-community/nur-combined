{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.whoogle-search;
in
{
  options.services.whoogle-search = {
    enable = mkEnableOption (lib.mdDoc "A self-hosted, ad-free, privacy-respecting metasearch engine");
    package = lib.mkPackageOption pkgs "whoogle-search" { };
    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = lib.literalExpression ''
        {
          WHOOGLE_URL_PREFIX = "/whoogle";
        }
      '';
      description = lib.mdDoc "Environment variables to pass to whoogle-search instance.";
    };
    environmentFile = mkOption {
      type = with types; nullOr str;
      default = null;
      description = lib.mdDoc ''
        File in the format of an EnvironmentFile as described by systemd.exec(5).
      '';
    };
    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = lib.mdDoc "Address for whoogle-search to listen to.";
    };
    listenPort = mkOption {
      type = types.int;
      default = 5000;
      description = lib.mdDoc "Port for whoogle-search to bind to.";
    };
  };
  config = mkIf cfg.enable {
    systemd.services.whoogle-search = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ cfg.package ];
      environment = {
        CONFIG_VOLUME = "/var/lib/whoogle-search";
      } // cfg.environment;
      script = "whoogle-search --host ${cfg.listenAddress} --port ${toString cfg.listenPort}";
      serviceConfig = {
        Type = "simple";
        StateDirectory = "whoogle-search";
        User = "whoogle-search";
        Group = "whoogle-search";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateIPC = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        RestrictNamespaces = "yes";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        UMask = "0007";
      } // optionalAttrs (cfg.environmentFile != null) { EnvironmentFile = cfg.environmentFile; };
    };

    users.groups.whoogle-search = { };
    users.users.whoogle-search = {
      description = "Whoogle-search Daemon User";
      group = "whoogle-search";
      isSystemUser = true;
    };
  };
}
