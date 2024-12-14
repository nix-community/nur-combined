{ config, pkgs, lib, ... }:
let
  defaultPackage = pkgs.callPackage ../../../pkgs/applications/sccache { };

  cfg = config.services.sccache;

  schedulerCfg = cfg.scheduler;
  serverCfg = cfg.server;

  configFormat = pkgs.formats.toml { };
in {
  options.services.sccache = with lib; {
    package = mkOption {
      type = types.package;
      default = defaultPackage;
    };

    scheduler = {
      enable = mkEnableOption "sccache scheduler";

      publicAddress = mkOption {
        type = types.str;
        default = "127.0.0.1:10600";
      };

      clientAuthToken = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      clientAuthTokenFile = mkOption {
        type = with types; nullOr path;
        default = null;
      };

      serverAuthToken = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      serverAuthTokenFile = mkOption {
        type = with types; nullOr path;
        default = null;
      };

      extraConfig = mkOption {
        type = configFormat.type;
        default = { };
      };
    };

    server = {
      enable = mkEnableOption "sccache build server";

      cacheDir = mkOption {
        type = types.path;
        default = "/var/lib/sccache-server/toolchains";
      };

      publicAddress = mkOption {
        type = types.str;
      };

      schedulerUrl = mkOption {
        type = types.str;
      };

      builder = {
        type = mkOption {
          type = types.enum [ "docker" "overlay" ];
          default = "overlay";
        };

        buildDir = mkOption {
          type = types.path;
          default = "/var/lib/sccache-server/build";
        };
      };

      schedulerAuthToken = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      schedulerAuthTokenFile = mkOption {
        type = with types; nullOr path;
        default = null;
      };

      extraConfig = mkOption {
        type = configFormat.type;
        default = { };
      };
    };
  };

  config = with lib; mkMerge [
    (mkIf schedulerCfg.enable (let
      package = cfg.package.override {
        enableDistServer = true;
      };

      baseConfig = {
        public_addr = schedulerCfg.publicAddress;

        client_auth.type = "token";
        server_auth.type = "jwt_hs256";
      } // schedulerCfg.extraConfig;
      baseConfigFile = configFormat.generate "sccache-scheduler-config.toml" baseConfig;
    in {
      assertions = [
        {
          assertion = lib.xor (schedulerCfg.clientAuthToken != null) (schedulerCfg.clientAuthTokenFile != null);
          message = "Either clientAuthToken or clientAuthTokenFile should be defined";
        }
        {
          assertion = lib.xor (schedulerCfg.serverAuthToken != null) (schedulerCfg.serverAuthTokenFile != null);
          message = "Either serverAuthToken or serverAuthTokenFile should be defined";
        }
      ];

      systemd.services.sccache-scheduler = {
        description = "SCCache Scheduler";
        wantedBy = [ "multi-user.target" ];

        path = with pkgs; [ dasel ];

        preStart = let
          clientAuthToken = if schedulerCfg.clientAuthToken != null
            then schedulerCfg.clientAuthToken
            else "$(cat ${schedulerCfg.clientAuthTokenFile})";
          serverAuthToken = if schedulerCfg.serverAuthToken != null
            then schedulerCfg.serverAuthToken
            else "$(cat ${schedulerCfg.serverAuthTokenFile})";
        in ''
          cat ${baseConfigFile} | \
            dasel put -r toml -v "${clientAuthToken}" client_auth.token | \
            dasel put -r toml -v "${serverAuthToken}" server_auth.secret_key > $RUNTIME_DIRECTORY/config.toml
        '';

        environment = {
          SCCACHE_NO_DAEMON = "1";
          SCCACHE_LOG = "info";
        };

        serviceConfig = {
          ExecStart = "${package}/bin/sccache-dist scheduler --config /run/sccache-scheduler/config.toml";

          RuntimeDirectory = "sccache-scheduler";
        };
      };
    }))
    (mkIf serverCfg.enable (let
      package = cfg.package.override {
        enableDistServer = true;
      };

      builderConfig =
        if serverCfg.builder.type == "docker" then {
          type = "docker";
        } else if serverCfg.builder.type == "overlay" then {
          type = "overlay";

          build_dir = serverCfg.builder.buildDir;
          bwrap_path = "${pkgs.bubblewrap}/bin/bwrap";
        } else throw "Unreachable";
      baseConfig = {
        cache_dir = serverCfg.cacheDir;
        public_addr = serverCfg.publicAddress;
        scheduler_url = serverCfg.schedulerUrl;

        builder = builderConfig;

        scheduler_auth.type = "jwt_token";
      } // serverCfg.extraConfig;
      baseConfigFile = configFormat.generate "sccache-server-config.toml" baseConfig;
    in {
      assertions = [
        {
          assertion = lib.xor (serverCfg.schedulerAuthToken != null) (serverCfg.schedulerAuthTokenFile != null);
          message = "Either schedulerAuthToken or schedulerAuthTokenFile should be defined";
        }
      ];

      systemd.services.sccache-server = {
        description = "SCCache Server";
        wantedBy = [ "multi-user.target" ];

        path = with pkgs; [ dasel ];

        preStart = let
          schedulerAuthToken = if serverCfg.schedulerAuthToken != null
            then serverCfg.schedulerAuthToken
            else "$(cat ${serverCfg.schedulerAuthTokenFile})";
        in ''
          cat ${baseConfigFile} | \
            dasel put -r toml -v "${schedulerAuthToken}" scheduler_auth.token > $RUNTIME_DIRECTORY/config.toml
        '';

        environment = {
          SCCACHE_NO_DAEMON = "1";
          SCCACHE_LOG = "info";
        };

        serviceConfig = {
          ExecStart = "${package}/bin/sccache-dist server --config /run/sccache-server/config.toml";

          StateDirectory = "sccache-server";
          RuntimeDirectory = "sccache-server";
        };
      };
    }))
  ];
}
