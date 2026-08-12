{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.cascade;
  format = pkgs.formats.toml { };
  configFile = format.generate "cascade.toml" cfg.settings;
  hsmConfigFile = format.generate "cascade-hsm-bridge.toml" cfg.hsmBridge.settings;
in
{
  options.services.cascade = {
    enable = lib.mkEnableOption "Cascade DNSSEC signing daemon";
    package = lib.mkPackageOption pkgs "cascade" { };
    dnstPackage = lib.mkPackageOption pkgs "dnst" { };
    settings = lib.mkOption {
      inherit (format) type;
      default = { };
      description = ''
        Settings for cascaded. See {manpage}`cascaded-config.toml(5)` for supported
        values. Note that `version` is required and defaults to `"v1"`.
      '';
      example = lib.literalExpression ''
        {
          daemon.log-level = "debug";
          server.servers = [ "0.0.0.0:53" "[::]:53" ];
        }
      '';
    };
    hsmBridge = {
      enable = lib.mkEnableOption "cascade-hsm-bridge, a KMIP to PKCS#11 bridge";
      package = lib.mkPackageOption pkgs "cascade-hsm-bridge" { };
      settings = lib.mkOption {
        inherit (format) type;
        default = { };
        description = "Settings for cascade-hsm-bridge.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.cascade.settings = {
      version = lib.mkDefault "v1";
      policy-dir = lib.mkDefault "/etc/cascade/policies";
      zone-state-dir = lib.mkDefault "/var/lib/cascade/zone-state";
      tsig-store-path = lib.mkDefault "/var/lib/cascade/tsig-keys.db";
      kmip-credentials-store-path = lib.mkDefault "/var/lib/cascade/kmip/credentials.db";
      keys-dir = lib.mkDefault "/var/lib/cascade/keys";
      kmip-server-state-dir = lib.mkDefault "/var/lib/cascade/kmip";
      dnst-binary-path = lib.mkDefault (lib.getExe' cfg.dnstPackage "dnst");

      daemon = lib.mkDefault {
        log-level = "info";
        log-target.type = "stdout";
        daemonize = false;
      };

      remote-control = lib.mkDefault {
        servers = [
          "127.0.0.1:4539"
          "[::1]:4539"
        ];
      };

      loader = lib.mkDefault {
        notify-listeners = [
          "127.0.0.1:4540"
          "[::1]:4540"
        ];
        review.servers = [
          "127.0.0.1:4541"
          "[::1]:4541"
        ];
      };

      signer = lib.mkDefault {
        review.servers = [
          "127.0.0.1:4542"
          "[::1]:4542"
        ];
      };

      server = lib.mkDefault {
        servers = [
          "127.0.0.1:4543"
          "[::1]:4543"
        ];
      };
    };

    services.cascade.hsmBridge.settings = lib.mkIf cfg.hsmBridge.enable {
      version = lib.mkDefault "v1";
      daemon = lib.mkDefault {
        log-level = "info";
        log-target.type = "stdout";
        daemonize = false;
      };
    };

    systemd.services.cascaded = {
      description = "Cascade DNSSEC Signer";
      documentation = [
        "man:cascaded(1)"
        "man:cascaded-config.toml(5)"
      ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${lib.getExe' cfg.package "cascaded"} --state=\${STATE_DIRECTORY}/state.db --config=${configFile}";
        ConfigurationDirectory = "cascade";
        StateDirectory = "cascade";
        Restart = "on-failure";
        DynamicUser = true;

        # Hardening
        LockPersonality = true;
        PrivateTmp = true;
        MemoryDenyWriteExecute = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        NoNewPrivileges = true;
        ProtectHome = true;
        ProtectSystem = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        RestrictRealtime = true;
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";
      };
    };

    systemd.services.cascade-hsm-bridge = lib.mkIf cfg.hsmBridge.enable {
      description = "KMIP to PKCS#11 bridge for Cascade";
      documentation = [ "man:cascade-hsm-bridge(1)" ];
      after = [
        "network.target"
        "cascaded.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${lib.getExe cfg.hsmBridge.package} --config=${hsmConfigFile}";
        Restart = "on-failure";
        DynamicUser = true;
      };
    };
  };
}
