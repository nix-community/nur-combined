{ config, lib, pkgs, ... }: {

  home.packages = with pkgs; [ sway-contrib.grimshot wl-clipboard wofi ];

  programs.mako.enable = true;

  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        modules-left = [ "sway/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" ];
        modules = {
          "clock" = {
            tooltip = true;
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
            today-format = "<b><u>{}</u></b>";
            format = "{:%H:%M (%a)}";
          };
        };
      }
      {
        layer = "top";
        position = "bottom";
        modules-left = [ "sway/window" ];
        modules-center = [ ];
        modules-right = [ "network" "cpu" "memory" "battery" ];
        modules = {
          "network" = {
            format = "{ifname}";
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ifname} ";
            format-disconnected = "";
            tooltip-format = "{bandwidthUpBits} | {bandwidthDownBits}";
            tooltop-format-disconnected = "OFFLINE";
          };
        };
      }
    ];
    systemd.enable = true;
  };

  services.kanshi.enable = true;

  services.udiskie.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    config = {
      bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];
      input."type:touchpad".tap = "enabled";
      keybindings =
        let modifier = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          "${modifier}+b" = "exec firefox";
          "${modifier}+p" =
            "exec ${pkgs.wofi}/bin/wofi -S run,drun | ${pkgs.findutils}/bin/xargs swaymsg exec --";
          "XF86MonBrightnessUp" = "exec light -A 5";
          "XF86MonBrightnessDown" = "exec light -U 5";
        };
      modifier = "Mod4";
      terminal = "${pkgs.termite}/bin/termite -e tmux";
    };
  };
}
