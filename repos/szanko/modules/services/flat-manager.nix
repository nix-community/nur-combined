{ lib, pkgs, config, ... }:

let
  cfg = config.services.flat-manager;

  # Render config.json from cfg.settings (attrset)
  configJson = pkgs.writeText "flat-manager-config.json"
    (builtins.toJSON cfg.settings);

in
{
  options.services.flat-manager = {
    enable = lib.mkEnableOption "flat-manager Flatpak repository server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.flat-manager or pkgs.callPackage ./flat-manager-pkg.nix {};
      description = "flat-manager package to run.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "flat-manager";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "flat-manager";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/flat-manager";
      description = "Directory holding repos/build-repo-base, etc.";
    };

    # Optional: load extra env vars (e.g. DATABASE_URL for diesel, etc.)
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "systemd EnvironmentFile to load (like a .env).";
    };

    # The full config.json structure flat-manager expects.
    # Keep it “as close to upstream” as possible to reduce friction.
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Contents of flat-manager config.json (as a Nix attrset).";
      example = {
        "database-url" = "postgres://%2Fvar%2Frun%2Fpostgresql/repo";
        "secret" = "c2VjcmV0";
        "repos" = [
          {
            name = "stable";
            path = "/var/lib/flat-manager/repo";
            "build-repo-base" = "/var/lib/flat-manager/build-repo";
          }
        ];
      };
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
    };

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
  };

  config = lib.mkIf cfg.enable {

    users.users = lib.mkIf (cfg.user == "flat-manager") {
      flat-manager = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.stateDir;
      };
    };

    users.groups = lib.mkIf (cfg.group == "flat-manager") {
      flat-manager = {};
    };

    # Ensure directories exist (repos must be on same filesystem for hardlinks)
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.flat-manager = {
      description = "flat-manager";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "postgresql.service" ];
      environment = {
        REPO_CONFIG = configJson;
      };

      # If you want to mimic .env loading:
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.stateDir;
        ExecStart = "${cfg.package}/bin/flat-manager --host ${cfg.listenAddress} --port ${toString cfg.listenPort}";
        Restart = "on-failure";

        # Optional: provide .env-like file
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
      };
    };
  };
}

