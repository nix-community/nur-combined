{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.services.goatcounter;

  inherit (lib)
    optionalAttrs
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    types;

  encodeParams = params: lib.concatStringsSep "&" (lib.mapAttrsToList (n: v: "${n}=${v}") params);
  encoder = {
    bool = n: v: lib.optionalString v "-${n}";
    int = n: v: "-${n} ${toString v}";
    list = n: v: "-${n} ${lib.concatStringsSep "," v}";
    string = n: v: "-${n} ${v}";
  };
  mkArgs = args: lib.concatStringsSep " " (lib.mapAttrsToList (n: v: (encoder.${builtins.typeOf v} n v)) args);
in
{
  options.services.goatcounter = {
    enable = mkEnableOption "Easy web analytics. No tracking of personal data.";

    user = mkOption {
      type = types.str;
      default = "goatcounter";
      description = "User account under which goatcounter runs.";
    };

    group = mkOption {
      type = types.str;
      default = "goatcounter";
      description = "Group under which goatcounter runs.";
    };

    package = mkPackageOption pkgs "goatcounter" { };

    homeDir = mkOption {
      type = types.path;
      default = "/var/lib/goatcounter";
      description = "Home directory for goatcounter user.";
    };

    database = mkOption {
      default = {
        type = "sqlite";
        file = "db/goatcounter.sqlite3";
      };

      type = types.submodule {
        options = {
          type = mkOption {
            type = types.enum [ "sqlite" "postgresql" ];
            default = "sqlite";
            description = "Database engine to use.";
          };

          file = mkOption {
            type = with types; nullOr str;
            default = null;
            description = "(sqlite) database file to use.";
          };

          params = mkOption {
            type = with types; attrsOf str;
            default = { };
            description = "Database connection parameters. See `goatcounter help db`";
          };
        };
      };
    };

    listenAddress = mkOption {
      type = types.str;
      default = "*";
      description = "Start the server on the specified address.";
    };

    port = mkOption {
      type = types.port;
      default = 8581;
      description = "Port for goatcounter to listen on.";
    };


    settings = mkOption {
      type = types.submodule rec {
        freeformType = types.anything;

        options = {
          tls =
            let
              values = (types.enum [ "http" "proxy" "tls" "rdr" "acme" ]);
            in
            mkOption {
              type = with types; either str (nonEmptyListOf values);
              default = [ "acme" "rdr" ];
              description = "Whether and how to handle TLS connections. See `goatcounter help listen`";
            };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.goatcounter.settings = {
      listen = lib.mkDefault "${cfg.listenAddress}:${toString cfg.port}";
      db = lib.mkDefault "${cfg.database.type}+${cfg.database.file}?${encodeParams cfg.database.params}";
    };

    systemd.services.goatcounter = {
      description = "Goatcounter web analytics";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/goatcounter serve ${mkArgs cfg.settings}";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.homeDir;
        ReadWritePaths = [ cfg.homeDir ];
      } // optionalAttrs (cfg.port < 1024) {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      };
    };

    users.users = optionalAttrs (cfg.user == "goatcounter") {
      goatcounter = {
        inherit (cfg) group;
        home = cfg.homeDir;
        createHome = true;
        isSystemUser = true;
      };
    };

    users.groups = optionalAttrs (cfg.group == "goatcounter") {
      goatcounter = { };
    };

    environment.systemPackages = [ cfg.package ];
  };
}
