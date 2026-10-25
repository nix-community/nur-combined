{ config, lib, pkgs, ... }:

let
  cfg = config.programs.lazycat-cloud-client;
in
{
  options.programs.lazycat-cloud-client = {
    enable = lib.mkEnableOption "LazyCat Cloud desktop client";

    package = lib.mkPackageOption pkgs "lazycat-cloud-client" { };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to auto-start the LazyCat Cloud client on login.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
      pkgs.zenity
    ];

      xdg.desktopEntries.lzc-client = {
        name = "懒猫微服";
        exec = "${cfg.package}/bin/lzc-client-desktop";
        icon = "${cfg.package}/share/icons/hicolor/256x256/apps/lzc-client.png";
        categories = [ "Network" ];
        mimeType = [ "x-scheme-handler/lzc" ];
        settings = {
          Keywords = "lazycat;lzc;";
          StartupWMClass = "lzc-client-desktop";
        };
      };

    systemd.user.services.lzc-client-desktop = lib.mkIf cfg.autoStart {
      Unit = {
        Description = "LazyCat Cloud desktop client";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/lzc-client-desktop";
        Environment = [
          "PATH=${cfg.package}/bin:${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ ];
}
