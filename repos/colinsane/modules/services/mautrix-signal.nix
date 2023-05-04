{ config, lib, pkgs, ... }:

with lib;
let
  # TODO: upstream these "optional-dependencies"
  # - search that phrase in <nixpkgs:doc/languages-frameworks/python.section.md>
  pkg = pkgs.mautrix-signal.overridePythonAttrs (super: {
    propagatedBuildInputs = super.propagatedBuildInputs ++ (with pkgs.python3.pkgs; [
      # these optional deps come from mautrix-signal's "optional-requirements.txt"

      # #/e2be
      # python-olm>=3,<4
      # pycryptodome>=3,<4
      # unpaddedbase64>=1,<3
      # XXX: ^above already included in nixpkgs package

      # #/metrics
      # prometheus_client>=0.6,<0.17
      # XXX: ^above already included in nixpkgs package

      # #/formattednumbers
      # phonenumbers>=8,<9
      # XXX: ^above already included in nixpkgs package

      # #/qrlink
      # qrcode>=6,<8
      # Pillow>=4,<10
      # XXX: ^above already included in nixpkgs package

      # #/stickers
      # signalstickers-client>=3,<4

      # #/sqlite
      # aiosqlite>=0.16,<0.19
      aiosqlite
    ]);
  });
  dataDir = "/var/lib/mautrix-signal";
  registrationFile = "${dataDir}/signal-registration.yaml";
  cfg = config.services.mautrix-signal;
  settingsFormat = pkgs.formats.json {};
  settingsFile =
    settingsFormat.generate "mautrix-signal-config.json" cfg.settings;
in
{
  options = {
    services.mautrix-signal = {
      enable = mkEnableOption (lib.mdDoc "Mautrix-Signal, a Matrix-Signal puppeting bridge");

      settings = mkOption rec {
        apply = recursiveUpdate default;
        inherit (settingsFormat) type;
        default = {
          # defaults based on this upstream example config:
          # - <https://github.com/mautrix/signal/blob/master/mautrix_signal/example-config.yaml>
          homeserver = {
            address = "http://localhost:8008";
            software = "standard";
            # domain = "SETME";
          };

          appservice = rec {
            address = "http://${hostname}:${toString port}";
            hostname = "localhost";
            port = 29328;

            database = "sqlite:///${dataDir}/mautrix-signal.db";
            database_opts = {};
            bot_username = "signalbot";
          };

          bridge = {
            username_template = "signal_{userid}";
            permissions."*" = "relay";
            double_puppet_server_map = {};
            login_shared_secret_map = {};
          };

          logging = {
            version = 1;

            formatters.precise.format = "[%(levelname)s@%(name)s] %(message)s";

            handlers.console = {
              class = "logging.StreamHandler";
              formatter = "precise";
            };

            # log to console/systemd instead of file
            root = {
              level = "INFO";
              handlers = ["console"];
            };
          };
        };
        example = literalExpression ''
          {
            homeserver = {
              address = "http://localhost:8008";
              domain = "mydomain.example";
            };

            bridge.permissions = {
              "@admin:mydomain.example" = "admin";
              "mydomain.example" = "user";
            };
          }
        '';
        description = lib.mdDoc ''
          {file}`config.yaml` configuration as a Nix attribute set.
          Configuration options should match those described in
          [example-config.yaml](https://github.com/mautrix/signale/blob/master/mautrix_signal/example-config.yaml).
        '';
      };

      environmentFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = lib.mdDoc ''
          File containing environment variables to be passed to the mautrix-signal service,
          in which secret tokens can be specified securely by defining values for e.g.
          `MAUTRIX_SIGNAL_APPSERVICE_AS_TOKEN`,
          `MAUTRIX_SIGNAL_APPSERVICE_HS_TOKEN`

          These environment variables can also be used to set other options by
          replacing hierarchy levels by `.`, converting the name to uppercase
          and prepending `MAUTRIX_SIGNAL_`.
          For example, the first value above maps to
          {option}`settings.appservice.as_token`.

          The environment variable values can be prefixed with `json::` to have
          them be parsed as JSON. For example, `login_shared_secret_map` can be
          set as follows:
          `MAUTRIX_SIGNAL_BRIDGE_LOGIN_SHARED_SECRET_MAP=json::{"example.com":"secret"}`.
        '';
      };

      serviceDependencies = mkOption {
        type = with types; listOf str;
        default = optional config.services.matrix-synapse.enable "matrix-synapse.service";
        defaultText = literalExpression ''
          optional config.services.matrix-synapse.enable "matrix-synapse.service"
        '';
        description = lib.mdDoc ''
          List of Systemd services to require and wait for when starting the application service.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.groups.mautrix-signal = {};

    users.users.mautrix-signal = {
      group = "mautrix-signal";
      isSystemUser = true;
    };

    systemd.services.mautrix-signal = {
      description = "Mautrix-Signal, a Matrix-Signal puppeting bridge.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;
      path = [ pkgs.ffmpeg ];  # voice messages need `ffmpeg`

      # environment.HOME = dataDir;

      preStart = ''
        # generate the appservice's registration file if absent
        if [ ! -f '${registrationFile}' ]; then
          ${pkg}/bin/mautrix-signal \
            --generate-registration \
            --no-update \
            --base-config='${pkg}/${pkg.pythonModule.sitePackages}/mautrix_signal/example-config.yaml' \
            --config='${settingsFile}' \
            --registration='${registrationFile}'
        fi
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "always";

        User = "mautrix-signal";

        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;

        PrivateTmp = true;
        WorkingDirectory = pkg;
        StateDirectory = baseNameOf dataDir;
        UMask = "0027";
        EnvironmentFile = cfg.environmentFile;

        ExecStart = ''
          ${pkg}/bin/mautrix-signal \
            --config='${settingsFile}' \
            --no-update
        '';
      };
    };
  };
}
