{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.headless;
in {
  options.services.headless = {
    enable = mkEnableOption "via Wayland";
    user = mkOption {
      type = types.str;
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      services.xserver.enable = true;
      services.displayManager.autoLogin.enable = true;
      services.displayManager.autoLogin.user = cfg.user;
      services.displayManager.defaultSession = "labwc";
      services.xserver.displayManager.lightdm.greeter.enable = false;
      programs.labwc.enable = true;
      environment.systemPackages = with pkgs; [ alacritty ];
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
