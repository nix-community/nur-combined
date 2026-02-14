{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mcsmanager;
in
{
  options.services.mcsmanager = {
    daemon = {
      enable = lib.mkEnableOption "MCSManager daemon (game server instance manager)";
      package = lib.mkPackageOption pkgs "mcsmanager-daemon" {
        default = [
          "toyvo"
          "mcsmanager"
          "mcsmanager-daemon"
        ];
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 24444;
        description = "Port for the MCSManager daemon to listen on.";
      };
      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/mcsmanager/daemon";
        description = "Directory for MCSManager daemon state data.";
      };
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the daemon port in the firewall.";
      };
    };

    panel = {
      enable = lib.mkEnableOption "MCSManager web panel (management interface)";
      package = lib.mkPackageOption pkgs "mcsmanager-web" {
        default = [
          "toyvo"
          "mcsmanager"
          "mcsmanager-web"
        ];
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 23333;
        description = "Port for the MCSManager web panel to listen on.";
      };
      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/mcsmanager/web";
        description = "Directory for MCSManager web panel state data.";
      };
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the panel port in the firewall.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.daemon.enable {
      systemd.services.mcsmanager-daemon = {
        description = "MCSManager Daemon";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        preStart = ''
          # Symlink immutable files from Nix store into working directory
          ln -sfn ${cfg.daemon.package}/lib/mcsmanager/daemon/app.js app.js
          ln -sfn ${cfg.daemon.package}/lib/mcsmanager/daemon/app.js.map app.js.map
          ln -sfn ${cfg.daemon.package}/lib/mcsmanager/daemon/node_modules node_modules
          ln -sfn ${cfg.daemon.package}/lib/mcsmanager/daemon/package.json package.json
          ln -sfn ${cfg.daemon.package}/lib/mcsmanager/daemon/lib lib

          # Ensure mutable directories exist
          mkdir -p data logs
        '';

        serviceConfig = {
          Type = "simple";
          User = "mcsmanager";
          Group = "mcsmanager";
          WorkingDirectory = cfg.daemon.dataDir;
          ExecStart = "${pkgs.nodejs}/bin/node --max-old-space-size=8192 --enable-source-maps app.js";
          Restart = "on-failure";
          RestartSec = "5s";

          # Hardening
          ProtectSystem = "strict";
          ProtectHome = true;
          ReadWritePaths = [ cfg.daemon.dataDir ];
          PrivateTmp = true;
          NoNewPrivileges = true;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.daemon.dataDir} 0750 mcsmanager mcsmanager -"
      ];

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.daemon.openFirewall [ cfg.daemon.port ];
    })

    (lib.mkIf cfg.panel.enable {
      systemd.services.mcsmanager-panel = {
        description = "MCSManager Web Panel";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        preStart = ''
          # Symlink immutable files from Nix store into working directory
          ln -sfn ${cfg.panel.package}/lib/mcsmanager/web/app.js app.js
          ln -sfn ${cfg.panel.package}/lib/mcsmanager/web/app.js.map app.js.map
          ln -sfn ${cfg.panel.package}/lib/mcsmanager/web/node_modules node_modules
          ln -sfn ${cfg.panel.package}/lib/mcsmanager/web/package.json package.json
          ln -sfn ${cfg.panel.package}/lib/mcsmanager/web/public public

          # Ensure mutable directories exist
          mkdir -p data logs
        '';

        serviceConfig = {
          Type = "simple";
          User = "mcsmanager";
          Group = "mcsmanager";
          WorkingDirectory = cfg.panel.dataDir;
          ExecStart = "${pkgs.nodejs}/bin/node --max-old-space-size=8192 --enable-source-maps app.js";
          Restart = "on-failure";
          RestartSec = "5s";

          # Hardening
          ProtectSystem = "strict";
          ProtectHome = true;
          ReadWritePaths = [ cfg.panel.dataDir ];
          PrivateTmp = true;
          NoNewPrivileges = true;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.panel.dataDir} 0750 mcsmanager mcsmanager -"
      ];

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.panel.openFirewall [ cfg.panel.port ];
    })

    (lib.mkIf (cfg.daemon.enable || cfg.panel.enable) {
      users.users.mcsmanager = {
        isSystemUser = true;
        group = "mcsmanager";
        home = "/var/lib/mcsmanager";
      };
      users.groups.mcsmanager = { };
    })
  ];
}
