{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.gmnisrv;
in {
  options.services.gmnisrv = {
    enable = mkEnableOption "Simple Gemini protocol server";

    package = mkOption {
      type = types.package;
      default = pkgs.gmnisrv;
      defaultText = "pkgs.gmnisrv";
      description = "Which gmnisrv package to use.";
    };

    hostNames = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "example.com" ];
      description = "List of hostnames to respond to requests for.";
    };

    port = mkOption {
      type = types.port;
      default = 1965;
      description = "TCP port for gmnisrv to bind to.";
    };

    user = mkOption {
      type = types.str;
      default = "gmnisrv";
      description = "User under which gmnisrv is ran.";
    };

    group = mkOption {
      type = types.str;
      default = "gmnisrv";
      description = "Group under which gmnisrv is ran.";
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/gemini";
      description = "The gmnisrv home directory containing certificates.";
    };

    docBase = mkOption {
      type = types.str;
      default = "/srv/gemini";
      description = "Base directory for Gemini content.";
    }
  };

  config = mkIf cfg.enable {
    systemd.services.gmnisrv = {
      description = "Simple gemini server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p "${cfg.stateDir}/certs"
      '';
      serviceConfig = let
        configFile = pkgs.writeFile "gmnisrv.ini" ''
          listen=0.0.0.0:${cfg.port}
          [:tls]
          store=${cfg.stateDir}/certs
        '' + lib.concatMapStringsSep "\n" (hostname: ''
          [${hostname}]
          root=${cfg.docBase}/${hostname}
        '') cfg.hostNames;
      in {
        User = cfg.user;
        Group = cfg.group;
        LogsDirectory = "gmnisrv";
        ExecStart = "${cfg.package}/bin/gmnisrv -C ${configFile}";
        Restart = "always";
      };
    };

    users.users = optionalAttrs (cfg.user == "gmnisrv") {
      gmnisrv = {
        group = cfg.group;
        home = cfg.stateDir;
        createHome = true;
        uid = config.ids.uids.gmnisrv;
      };
    };

    users.groups = optionalAttrs (cfg.group == "gmnisrv") {
      gmnisrv.gid = config.ids.gids.gmnisrv;
    };
  };
}
