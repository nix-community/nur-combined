{ config, lib, pkgs, ... }: {

  home.packages = with pkgs; [
    pamixer
    sway-contrib.grimshot
    wl-clipboard
    wofi
    wob
  ];

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
            "exec ${pkgs.wofi}/bin/wofi -S drun | ${pkgs.findutils}/bin/xargs swaymsg exec --";
          "XF86AudioRaiseVolume" =
            "exec ${pkgs.pamixer}/bin/pamixer -ui 2 && pamixer --get-volume > $SWAYSOCK.wob";
          "XF86AudioLowerVolume" =
            "exec ${pkgs.pamixer}/bin/pamixer -ud 2 && pamixer --get-volume > $SWAYSOCK.wob";
          "XF86AudioMute" =
            "exec ${pkgs.pamixer}/bin/pamixer --toggle-mute && ( pamixer --get-mute && echo 0 > $SWAYSOCK.wob || pamixer --get-volume > $SWAYSOCK.wob";
          "XF86MonBrightnessUp" =
            "exec light -A 5 && light -G | cut -d'.' -f1 > $SWAYSOCK.wob";
          "XF86MonBrightnessDown" =
            "exec light -U 5 && light -G | cut -d'.' -f1 > $SWAYSOCK.wob";
        };
      menu =
        "exec ${pkgs.wofi}/bin/wofi -S run | ${pkgs.findutils}/bin/xargs swaymsg exec --";
      modifier = "Mod4";
      startup = [
        { command = "${pkgs.firefox}/bin/firefox"; }
        { command = "mkfifo $SWAYSOCK.wob && tail -f $SWAYSOCK.wob | wob"; }
      ];
      terminal = "${pkgs.termite}/bin/termite -e tmux";
    };
  };
}
