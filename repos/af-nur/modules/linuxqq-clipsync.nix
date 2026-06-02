{ config, lib, pkgs, ... }:

let
  programCfg = config.programs.linuxqq-clipsync;
  serviceCfg = config.services.linuxqq-clipsync;
  defaultPackage = pkgs.callPackage ../pkgs/linuxqq-clipsync { };
in
{
  options.programs.linuxqq-clipsync = {
    enable = lib.mkEnableOption "linuxqq-clipsync";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      defaultText = lib.literalExpression "pkgs.callPackage <nur-packages>/pkgs/linuxqq-clipsync { }";
      description = "linuxqq-clipsync package to install into the system profile.";
    };
  };

  options.services.linuxqq-clipsync = {
    enable = lib.mkEnableOption "linuxqq-clipsync user service";

    package = lib.mkOption {
      type = lib.types.package;
      default = programCfg.package;
      defaultText = lib.literalExpression "config.programs.linuxqq-clipsync.package";
      description = "linuxqq-clipsync package to run in the user service.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        DISPLAY = ":0";
        WAYLAND_DISPLAY = "wayland-1";
      };
      description = "Extra environment variables for the user service.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf programCfg.enable {
      environment.systemPackages = [ programCfg.package ];
    })

    (lib.mkIf serviceCfg.enable {
      systemd.user.services."linuxqq-clipsync" = {
        description = "Clipboard Sync (X11 <-> Wayland)";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        environment = serviceCfg.environment;

        serviceConfig = {
          Type = "simple";
          ExecStart = lib.getExe serviceCfg.package;
          Restart = "always";
          RestartSec = 3;
        };
      };
    })
  ];
}
