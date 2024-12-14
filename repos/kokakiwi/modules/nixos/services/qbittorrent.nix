{ config, pkgs, lib, ... }:
let
  cfg = config.services.qbittorrent;

  defaultOpenFilesLimit = 4096;

  configPath = "${cfg.dataDir}/qBittorrent/config/qBittorrent.conf";
  initConfigFile = let
    iniFormat = pkgs.formats.ini {
      listToValue = lib.concatStringsSep ",";
    };

    data = lib.flip lib.mapAttrs cfg.initSettings (_: section: let
      processEntry = prefix: name: value: if builtins.isAttrs value
        then lib.flatten (lib.mapAttrsToList (processEntry "${prefix}${name}\\") value)
        else lib.singleton (lib.nameValuePair "${prefix}${name}" value);
    in builtins.listToAttrs (lib.flatten (lib.mapAttrsToList (processEntry "") section)));
  in iniFormat.generate "qbittorrent.conf" data;
in {
  options.services.qbittorrent = with lib; {
    enable = mkEnableOption "qBittorrent";

    package = mkPackageOption pkgs "qbittorrent-nox" { };

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
    };
    group = mkOption {
      type = types.str;
      default = "qbittorrent";
    };

    openFilesLimit = mkOption {
      type = with types; either int str;
      default = defaultOpenFilesLimit;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
    };

    initSettings = mkOption {
      type = with types; attrsOf (attrsOf anything);
      default = { };
    };

    bittorrenPort = mkOption {
      type = types.port;
      default = 27461;
    };

    webuiAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };
    webuiPort = mkOption {
      type = types.port;
      default = 8080;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = with lib; mkIf cfg.enable {
    services.qbittorrent.initSettings = {
      Preferences = {
        WebUI = {
          Address = cfg.webuiAddress;
          Port = cfg.webuiPort;
        };
      };
      BitTorrent = {
        Session.Port = cfg.bittorrenPort;
      };
    };

    systemd.services."qbittorrent" = {
      description = "qBittorrent Daemon";

      path = [ cfg.package ];

      preStart = ''
        if [ ! -f ${configPath} ]; then
          mkdir -p $(dirname ${configPath})
          cp -T ${initConfigFile} ${configPath}

          chown -R ${cfg.user}:${cfg.group} $(dirname ${configPath})
        fi
      '';

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/qbittorrent-nox --profile=${cfg.dataDir}";

        Restart = "on-success";

        User = cfg.user;
        Group = cfg.group;

        UMask = "0002";
        LimitNOFILE = cfg.openFilesLimit;
      };

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} -"
    ];

    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
      };
    };

    users.groups = mkIf (cfg.group == "qbittorrent") {
      qbittorrent = {};
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.webuiPort ];
    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ cfg.bittorrenPort ];
  };
}
