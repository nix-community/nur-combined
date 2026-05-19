# from https://github.com/NickCao/nixpkgs/blob/50c68a69fd579c02983e642044023bb2226dc6fd/nixos/modules/services/matrix/mautrix-telegram.nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  dataDir = "/var/lib/mautrix-telegram";
  registrationFile = "${dataDir}/telegram-registration.yaml";
  cfg = config.services.mautrix-telegram;
  settingsFormat = pkgs.formats.json { };
  settingsFileUnsubstituted = settingsFormat.generate "mautrix-telegram-config.json" cfg.settings;
  settingsFile = "${dataDir}/config.json";
in
{
  # disable existing module in nixpkgs
  disabledModules = [ "services/matrix/mautrix-telegram.nix" ];

  options.services.mautrix-telegram = {
    enable = lib.mkEnableOption "Mautrix-Telegram, a Matrix-Telegram hybrid puppeting/relaybot bridge";

    package = lib.mkPackageOption pkgs "mautrix-telegram" { };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
      };
      default = { };
      description = ''
        {file}`config.yaml` configuration as a Nix attribute set.

        For the go version (`pkgs.mautrix-telegram-go`), see configuration options in
        [example-config.yaml](https://docs.mau.fi/configs/mautrix-telegram/latest)

        Secret tokens should be specified using {option}`environmentFile`
        instead of this world-readable attribute set.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        File containing environment variables to be passed to the mautrix-telegram service.
      '';
    };

    serviceDependencies = lib.mkOption {
      type = with lib.types; listOf str;
      default = lib.optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit;
      defaultText = lib.literalExpression ''
        lib.optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit
      '';
    };

    registerToSynapse = lib.mkOption {
      type = lib.types.bool;
      default = config.services.matrix-synapse.enable;
      defaultText = lib.literalExpression "config.services.matrix-synapse.enable";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mautrix-telegram.settings = {
      appservice = {
        address = lib.mkDefault "http://localhost:${toString cfg.settings.appservice.port}";
        port = lib.mkDefault 8080;
      };
      database = {
        type = lib.mkDefault "sqlite3-fk-wal";
        uri = lib.mkDefault "file:${dataDir}/mautrix-telegram.db?_txlock=immediate";
      };
      env_config_prefix = "MAUTRIX_TELEGRAM_";
    };

    users.users.mautrix-telegram = {
      isSystemUser = true;
      group = "mautrix-telegram";
      home = dataDir;
      description = "Mautrix-Telegram bridge user";
    };

    users.groups.mautrix-telegram = { };

    services.matrix-synapse = lib.mkIf cfg.registerToSynapse {
      settings.app_service_config_files = [ registrationFile ];
    };
    systemd.services.matrix-synapse = lib.mkIf cfg.registerToSynapse {
      serviceConfig.SupplementaryGroups = [ "mautrix-telegram" ];
    };

    systemd.services.mautrix-telegram = {
      description = "Mautrix-Telegram, a Matrix-Telegram hybrid puppeting/relaybot bridge.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;
      path = with pkgs; [
        lottieconverter
        ffmpeg-headless
      ];

      preStart = ''
        # substitute the settings file by environment variables
        # in this case read from EnvironmentFile
        test -f '${settingsFile}' && rm -f '${settingsFile}'
        old_umask=$(umask)
        umask 0177
        ${pkgs.envsubst}/bin/envsubst \
          -o '${settingsFile}' \
          -i '${settingsFileUnsubstituted}'
        umask $old_umask

        # generate the appservice's registration file if absent
        if [ ! -f '${registrationFile}' ]; then
          ${lib.getExe cfg.package} \
            --generate-registration \
            --config='${settingsFile}' \
            --registration='${registrationFile}'
        fi

        old_umask=$(umask)
        umask 0177
        # 1. Overwrite registration tokens in config
        #    is set, set it as the login shared secret value for the configured
        #    homeserver domain.
        ${pkgs.yq}/bin/yq -s '.[0].appservice.as_token = .[1].as_token
          | .[0].appservice.hs_token = .[1].hs_token
          | .[0]' \
          '${settingsFile}' '${registrationFile}' > '${settingsFile}.tmp'
        mv '${settingsFile}.tmp' '${settingsFile}'

        umask $old_umask
      '';

      serviceConfig = {
        User = "mautrix-telegram";
        Group = "mautrix-telegram";
        Type = "simple";
        Restart = "always";

        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;

        PrivateTmp = true;
        StateDirectory = baseNameOf dataDir;
        UMask = "0027";
        EnvironmentFile = cfg.environmentFile;

        ExecStart = "${lib.getExe cfg.package} --config='${settingsFile}'";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
