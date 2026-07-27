{ config, lib, pkgs, nixosConfig, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.qogir-icon-theme;
    name = "Qogir";
    size = 24;
  };

  programs = {
    kitty = {
      enable = true;
      # shellIntegration.enableZshIntegration = true;
      settings = {
        term = "xterm-256color";
        close_on_child_death = "yes";
        font_family = "JetBrains Mono";
        tab_bar_edge = "top";
        listen_on = "unix:/tmp/my kitty";
        allow_remote_control = "yes";
        macos_option_as_alt = "yes";
        copy_on_select = "yes";

        active_tab_foreground = "#C6A0F6";
        active_tab_background = "#0c0c0c";
        inactive_tab_foreground = "#6E738D";
        inactive_tab_background = "#0c0c0c";
      };
      font = {
        name = "JetBrains Mono";
        size = 12;
      };
      keybindings = {
        "shift+left" = "neighboring_window left";
        "shift+right" = "neighboring_window right";
        "shift+up" = "neighboring_window up";
        "shift+down" = "neighboring_window down";
      };
      theme = "Tango Light";
      # action_alias mkh kitten hints --alphabet asdfghjklqwertyuiopzxcvbnmASDFGHJKLQWERTYUIOPZXCVBNM 
      # map kitty_mod+n    mkh --type=linenum emacsclient -c -nw +{line} {path}
    };
  };
  services = {
    blueman-applet.enable = nixosConfig.modules.hardware.bluetooth.enable;
    pasystray.enable = nixosConfig.modules.hardware.audio.enable;
    udiskie.enable = true;
    # network-manager-applet.enable = true;
    gammastep = {
      enable = true;
      provider = "geoclue2";
      # longitude = "2.333333";
      # latitude = "48.866667";
    };
    kanshi = {
      enable = true;
      settings = [
        {
          profile.name = "home-undocked";
          profile.outputs = [
            # Output eDP-1 'AU Optronics 0xD291 Unknown'
            { criteria = "eDP-1"; status = "enable"; position = "0,0"; mode = "1920x1200"; scale = 1.0; }
          ];
        }
        {
          profile.name = "home-docked";
          profile.outputs = [
            # Old: Output eDP-1 'AU Optronics 0xD291 Unknown'
            # Output eDP-1 'Unknown 0xD291 Unknown'
            # Output DP-5 'LG Electronics LG ULTRAWIDE 0x0005D10C' (focused)
            # { criteria = "LG Electronics LG ULTRAWIDE 0x0000D50C"; status = "enable"; position = "0,0"; mode = "3440x1440"; scale = 1.0; }
            { criteria = "DP-5"; status = "enable"; position = "0,0"; mode = "3440x1440"; scale = 1.0; }
            # Use it as a "shareable" screen when needed
            { criteria = "eDP-1"; status = "enable"; position = "1460,1440"; mode = "1920x1200"; scale = 1.0; }
          ];
        }
      ];
    };
    mako = {
      enable = true;
      font = "JetBrains Mono 12";
      defaultTimeout = 8000; # 5s timeout
      groupBy = "app-name,summary";
      # FIXME: hide pulseaudio notifications (maybe they don't show up without pasystray)
      extraConfig = ''
width=400
on-button-left=dismiss
on-button-middle=invoke-default-action
on-button-right=dismiss
border-radius=6
border-size=3
border-color=#db7508
format=<b>%s</b>\n%b\n<i>%a</i>
icon-path=/run/current-system/sw/share/icons/Qogir-dark:/run/current-system/sw/share/icons/hicolor

[urgency=low]
background-color=#282c30
text-color=#888888
default-timeout=2000

[urgency=normal]
background-color=#282c30
text-color=#ffffff
default-timeout=5000

[urgency=high]
background-color=#900000
text-color=#ffffff
border-color=#ff0000

[app-name="pa-notify"]
background-color=#0080ff
text-color=#333333
anchor=bottom-right
format=<b>%s</b>\n%b

[category="build"]
anchor=bottom-right
format=<b>%s</b>\n%b

[category="recording"]
anchor=bottom-right
format=<b>%s</b>\n%b

[category="info"]
anchor=center
format=<b>%s</b> %b

#[app-name="Google Chrome" body~="calendar.google.com.*"]
#max-visible=2

[mode=do-not-disturb]
invisible=1
      '';
    };
    swayidle = {
      enable = false;
      events = [
        { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock --daemonize -i $HOME/desktop/pictures/lockscreen"; }
        { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock --daemonize -i $HOME/desktop/pictures/lockscreen"; }
      ];
      timeouts = [
        { timeout = 600; command = "${pkgs.swaylock}/bin/swaylock --daemonize -i $HOME/desktop/pictures/lockscreen"; }
        {
          timeout = 1200;
          command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
          resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
        }
      ];
    };
  };
  home.packages = with pkgs; [
    swaylock
    swayidle
    wf-recorder
    wl-clipboard
    wtype
    mako
    wofi
    slurp
    grim
    zenity
    qogir-icon-theme
    cliphist
  ];
}
