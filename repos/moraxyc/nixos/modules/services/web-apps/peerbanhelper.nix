{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.peerbanhelper;
  settingsFormat = pkgs.formats.yaml { };

  toEnvValue = value: if lib.isBool value then lib.boolToString value else toString value;

  bindPrivileged = cfg.port < 1024;
  hasConfig = cfg.settings != { } || cfg.profileSettings != { };

  proxyHost =
    if cfg.listenAddress == "0.0.0.0" then
      "127.0.0.1"
    else if cfg.listenAddress == "::" then
      "::1"
    else
      cfg.listenAddress;
  proxyPass = "http://${
    if lib.hasInfix ":" proxyHost then "[${proxyHost}]" else proxyHost
  }:${toString cfg.port}";

  genConfig = pkgs.writeShellApplication {
    name = "gen-peerbanhelper-config";
    runtimeInputs = with pkgs; [
      coreutils
      unzip
      yq-go
    ];
    text =
      let
        renderYaml =
          name: settings: defaultResource: targetFile:
          lib.optionalString (settings != { }) (
            ''
              ${utils.genJqSecretsReplacementSnippet settings "/run/peerbanhelper/${name}.json"}
              yq -o=yaml /run/peerbanhelper/${name}.json > /run/peerbanhelper/${name}.override.yml
            ''
            + lib.optionalString cfg.mutableConfig ''
              if [ ! -f ${targetFile} ]; then
                unzip -p ${lib.escapeShellArg "${cfg.package}/share/peerbanhelper/PeerBanHelper.jar"} ${defaultResource} > /run/peerbanhelper/${name}.base.yml
                yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
                  /run/peerbanhelper/${name}.base.yml /run/peerbanhelper/${name}.override.yml > /run/peerbanhelper/${name}.merged.yml
              else
                yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
                  ${targetFile} /run/peerbanhelper/${name}.override.yml > /run/peerbanhelper/${name}.merged.yml
              fi
            ''
            + lib.optionalString (!cfg.mutableConfig) ''
              unzip -p ${lib.escapeShellArg "${cfg.package}/share/peerbanhelper/PeerBanHelper.jar"} ${defaultResource} > /run/peerbanhelper/${name}.base.yml
              yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
                /run/peerbanhelper/${name}.base.yml /run/peerbanhelper/${name}.override.yml > /run/peerbanhelper/${name}.merged.yml
            ''
            + ''
              install -m 0600 /run/peerbanhelper/${name}.merged.yml ${targetFile}
              rm -f /run/peerbanhelper/${name}.json /run/peerbanhelper/${name}.override.yml /run/peerbanhelper/${name}.base.yml /run/peerbanhelper/${name}.merged.yml
            ''
          );
      in
      ''
        install -d -m 0750 /var/lib/peerbanhelper/config
      ''
      + renderYaml "config" cfg.settings "config.yml" "/var/lib/peerbanhelper/config/config.yml"
      + renderYaml "profile" cfg.profileSettings "profile.yml" "/var/lib/peerbanhelper/config/profile.yml"
      + ''
        chown -R --reference=/run/peerbanhelper /var/lib/peerbanhelper/config
      '';
  };
in
{
  options.services.peerbanhelper = {
    enable = lib.mkEnableOption "PeerBanHelper, an automated BitTorrent anti-leech tool";

    package = lib.mkPackageOption pkgs "peerbanhelper" { };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = ''
        Address on which the PeerBanHelper WebUI server listens.
        Overrides `server.address` in `config.yml` via `PBH_SERVERADDRESS`.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9898;
      description = ''
        TCP port on which the PeerBanHelper WebUI server listens.
        Overrides `server.http` in `config.yml` via `PBH_PORT`.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to open {option}`services.peerbanhelper.port` in the firewall.
      '';
    };

    configureNginx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to configure nginx as a reverse proxy for PeerBanHelper.
      '';
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      example = "pbh.example.org";
      description = ''
        Domain name for the nginx virtual host.
      '';
    };

    apiTokenFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/peerbanhelper-token";
      description = ''
        File containing the WebUI API token, loaded via systemd `LoadCredential`
        and exported as `PBH_APITOKEN`. When set, this overrides `server.token`
        in `config.yml` and bypasses the initial WebUI OOBE token setup.
      '';
    };

    mutableConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Allow PeerBanHelper to persist WebUI changes in `config.yml` and
        `profile.yml` across restarts. When enabled and
        {option}`services.peerbanhelper.settings` or
        {option}`services.peerbanhelper.profileSettings` is non-empty, declared
        values are merged onto the existing configuration files before startup.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
      };
      default = { };
      example = {
        language = "zh_cn";
        privacy.analytics = false;
        ip-database.auto-update = false;
      };
      description = ''
        Declarative overrides merged into `/var/lib/peerbanhelper/config/config.yml`.
        Leave empty to let PeerBanHelper initialize and manage `config.yml`
        exclusively through the WebUI.

        Options containing secret data may be set to an attribute set
        containing the `_secret` attribute, pointing to a file whose content
        replaces the value at service startup.
      '';
    };

    profileSettings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
      };
      default = { };
      example = {
        check-interval = 5000;
        module.progress-cheat-blocker.enabled = true;
      };
      description = ''
        Declarative overrides merged into `/var/lib/peerbanhelper/config/profile.yml`.
        Leave empty to let PeerBanHelper initialize and manage `profile.yml`
        exclusively through the WebUI.

        Options containing secret data may be set to an attribute set
        containing the `_secret` attribute, pointing to a file whose content
        replaces the value at service startup.
      '';
    };

    environment = lib.mkOption {
      type =
        with lib.types;
        attrsOf (oneOf [
          bool
          int
          str
        ]);
      default = { };
      example = {
        PBH_LOG_LEVEL = "DEBUG";
        PBH_USERLOCALE = "zh_cn";
      };
      description = ''
        Additional environment variables passed to PeerBanHelper (such as
        `PBH_*` external switches).
      '';
    };

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/peerbanhelper.env";
      description = ''
        Environment file read by systemd, for secrets or extra `PBH_*`
        variables. Variables set here override
        {option}`services.peerbanhelper.environment`.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "pbh.forceDisableIPDB=true" ];
      description = ''
        Extra command-line arguments passed to `peerbanhelper`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;

    services.peerbanhelper.environment = {
      PBH_DATADIR = "/var/lib/peerbanhelper";
      PBH_LOGSDIR = "/var/log/peerbanhelper";
      PBH_NOGUI = "true";
      PBH_SERVERADDRESS = cfg.listenAddress;
      PBH_PORT = cfg.port;
    };

    services.nginx = lib.mkIf cfg.configureNginx {
      enable = lib.mkDefault true;
      virtualHosts.${cfg.domain} = {
        locations."/" = {
          inherit proxyPass;
          recommendedProxySettings = true;
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;
          '';
        };
      };
    };

    systemd.services.peerbanhelper = {
      description = "PeerBanHelper";
      documentation = [ "https://github.com/PBH-BTN/PeerBanHelper" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = lib.mapAttrs (_: toEnvValue) cfg.environment;

      script = ''
        if [ -n "''${CREDENTIALS_DIRECTORY:-}" ] && [ -r "$CREDENTIALS_DIRECTORY/api-token" ]; then
          PBH_APITOKEN="$(tr -d '\r\n' < "$CREDENTIALS_DIRECTORY/api-token")"
          export PBH_APITOKEN
        fi

        exec ${lib.getExe cfg.package} nogui ${lib.escapeShellArgs cfg.extraArgs}
      '';

      serviceConfig = {
        Type = "simple";
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        LoadCredential = lib.optional (cfg.apiTokenFile != null) "api-token:${cfg.apiTokenFile}";
        ExecStartPre = lib.optional hasConfig "+${lib.getExe genConfig}";

        DynamicUser = true;
        User = "peerbanhelper";
        Group = "peerbanhelper";

        WorkingDirectory = "/var/cache/peerbanhelper";
        Restart = "on-failure";
        RestartSec = "5s";

        StateDirectory = "peerbanhelper";
        StateDirectoryMode = "0750";
        LogsDirectory = "peerbanhelper";
        LogsDirectoryMode = "0750";
        CacheDirectory = "peerbanhelper";
        CacheDirectoryMode = "0750";
        RuntimeDirectory = lib.mkIf hasConfig "peerbanhelper";
        RuntimeDirectoryMode = lib.mkIf hasConfig "0750";

        # Hardening
        CapabilityBoundingSet = lib.optionalString bindPrivileged "CAP_NET_BIND_SERVICE";
        AmbientCapabilities = lib.optionalString bindPrivileged "CAP_NET_BIND_SERVICE";
        DeviceAllow = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = false; # Required by JVM JIT
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = !bindPrivileged;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
