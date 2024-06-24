{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.services.laminar;

  inherit (lib)
    literalExpression
    optionalAttrs
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    types;
in
{
  options.services.laminar = {
    enable = mkEnableOption "Lightweight and modular Continuous Integration service for Linux.";

    user = mkOption {
      type = types.str;
      default = "laminar";
      description = "User account under which laminar runs.";
    };

    group = mkOption {
      type = types.str;
      default = "laminar";
      description = "User account under which laminar runs.";
    };

    package = mkPackageOption pkgs "laminar" { };

    homeDir = mkOption {
      type = types.path;
      default = "/var/lib/laminar";
      description = "Home directory for laminar user.";
    };

    path = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        bash
        stdenv
        git
        nix
        config.programs.ssh.package
      ];
      defaultText = literalExpression "[ pkgs.stdenv pkgs.git pkgs.nix config.programs.ssh.package ]";
      description = "Packages added to service PATH environment variable.";
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration for laminar.

        See https://laminar.ohwg.net/docs.html#Service-configuration-file
      '';

      type = types.submodule {
        options = {
          bindHTTP = mkOption {
            type = types.str;
            default = "*:8080";
            description = "The interface/port or unix socket on which laminard should listen for incoming connections to the web frontend.";
          };
          bindRPC = mkOption {
            type = types.str;
            default = "unix-abstract:laminar";
            description = "The interface/port or unix socket on which laminard should listen for incoming commands such as build triggers.";
          };
          title = mkOption {
            type = types.str;
            default = "";
            description = "The page title to show in the web frontend.";
          };
          keepRundirs = mkOption {
            type = types.int;
            default = 0;
            description = "Set to an integer defining how many rundirs to keep per job. The lowest-numbered ones will be deleted.";
          };
          baseURL = mkOption {
            type = types.str;
            default = "/";
            description = "Base url for the frontend.";
          };
          archiveURL = mkOption {
            type = with types; nullOr str;
            default = null;
            example = "http://localhost:8080";
            description = "If set, the web frontend served by laminard will use this URL to form links to artefacts archived jobs.";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.laminar = {
      description = "Laminar continuous integration service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      inherit (cfg) path;
      environment = {
        XDG_RUNTIME_DIR = "%t/laminar";
      };
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/laminard -v";
        RuntimeDirectory = "laminar";
        EnvironmentFile = pkgs.writeText "laminar.conf" ''
          LAMINAR_HOME=${cfg.homeDir}
          LAMINAR_BIND_HTTP=${cfg.settings.bindHTTP}
          LAMINAR_BIND_RPC=${cfg.settings.bindRPC}
          LAMINAR_TITLE=${cfg.settings.title}
          LAMINAR_KEEP_RUNDIRS=${toString cfg.settings.keepRundirs}
          LAMINAR_BASE_URL=${cfg.settings.baseURL}
          ${lib.optionalString (cfg.settings.archiveURL != null)
            "LAMINAR_ARCHIVE_URL=${cfg.settings.archiveURL}"
          }
        '';
      };
      unitConfig = {
        Documentation = [
          "man:laminard(8)"
          "https://laminar.ohwg.net/docs.html"
        ];
      };
    };

    environment.systemPackages = [
      pkgs.laminar
    ];

    users.users = optionalAttrs (cfg.user == "laminar") {
      laminar = {
        inherit (cfg) group;
        home = cfg.homeDir;
        createHome = true;
        isSystemUser = true;
      };
    };

    users.groups = optionalAttrs (cfg.group == "laminar") {
      laminar = { };
    };
  };
}
