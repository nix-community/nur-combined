{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.headless;
in {
  options.services.headless = {
    wayland = mkEnableOption "via Wayland";
    autorun = mkEnableOption "run by default";
    user = mkOption {
      type = types.str;
    };
    commands = mkOption {
      type = types.str;
      default = "";
    };
    dummy = mkOption {
      type = types.bool;
      default = true;
      description = "Enable monitor emulation";
    };
    resolution = mkOption {
      type = types.nullOr types.attrs;
      default = if cfg.dummy then { x = 1920; y = 1080; } else null;
    };
    output = mkOption {
      type = types.str;
      default = if cfg.dummy then "HEADLESS-1" else "HDMI-A-1";
    };
  };
  config = mkMerge [
    (mkIf (cfg.wayland && cfg.dummy) {
      programs.sway.extraSessionCommands = ''
        export WLR_BACKENDS=headless sway
      '';
      systemd.user.services.headless = {
        wantedBy = optional cfg.autorun "default.target";
        description = "Graphical headless server";
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "sway" ''
            . /etc/set-environment
            sway
          '';
        };
      };
      users.extraUsers."${cfg.user}".linger = mkDefault true;
    })
    (mkIf (cfg.wayland && !cfg.dummy) {
      services.xserver.enable = true;
      services.xserver.autorun = cfg.autorun;
      services.displayManager.autoLogin.enable = true;
      services.displayManager.autoLogin.user = cfg.user;
      services.displayManager.defaultSession = "sway";
      services.xserver.displayManager.lightdm.greeter.enable = false;
    })
    (mkIf cfg.wayland {
      programs.sway.enable = true;
      environment.etc."sway/config.d/headless.conf".source = pkgs.writeText "headless.conf" (''
        ${cfg.commands}
      '' + optionalString (cfg.resolution != null) ''
        output ${cfg.output} resolution ${toString cfg.resolution.x}x${toString cfg.resolution.y}
      '');
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-ignore-inhibit" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
            action.id == "org.freedesktop.login1.set-reboot-parameter" ||
            action.id == "org.freedesktop.login1.set-reboot-to-firmware-setup" ||
            action.id == "org.freedesktop.login1.set-reboot-to-boot-loader-menu" ||
            action.id == "org.freedesktop.login1.set-reboot-to-boot-loader-entry" ||
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-ignore-inhibit" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions"
          ) {
            return polkit.Result.AUTH_SELF_KEEP;
          }
        });
      '';
    })
  ];
}
