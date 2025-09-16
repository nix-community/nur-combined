{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkOptionDefault
    ;
in {
  home-manager.users.alarsyo = {
    home.stateVersion = "23.11";

    my.home.laptop.enable = true;

    # Keyboard settings & i3 settings
    my.home.x.enable = true;
    my.home.x.i3bar.temperature.chip = "k10temp-pci-*";
    my.home.x.i3bar.temperature.inputs = ["Tctl"];
    my.home.x.i3bar.networking.throughput_interfaces = ["wlp1s0"];
    my.home.emacs.enable = true;

    my.theme = config.home-manager.users.alarsyo.my.themes.solarizedLight;

    services = {
      # TODO: place in global home conf
      dunst.enable = true;
      wlsunset = {
        enable = true;
        latitude = 48.9;
        longitude = 2.3;
        temperature = {
          day = 6500;
          night = 3500;
        };
      };
      darkman = {
        enable = true;
        settings = {
          lat = 48.9;
          lng = 2.3;
        };
      };
      playerctld.enable = true;
    };

    home.packages = builtins.attrValues {
      inherit
        (pkgs)
        #ansel
        chromium # some websites only work there :(
        font-awesome # for pretty icons
        gnome-solanum
        nwg-displays
        shikane # output autoconfig
        swaybg
        zotero
        grim
        wl-clipboard
        slurp
        ;

      inherit
        (pkgs.packages)
        spot
        ;
    };

    wayland.windowManager.sway = let
      logoutMode = "[L]ogout, [S]uspend, [P]oweroff, [R]eboot";
      lock = "swaylock --daemonize --image ~/.wallpaper --scaling fill";
    in {
      enable = true;
      swaynag.enable = true;
      wrapperFeatures.gtk = true;
      config = {
        modifier = "Mod4";
        input = {
          "type:keyboard" = {
            xkb_layout = "fr,fr";
            xkb_variant = "us,ergol";
            xkb_options = "grp:shift_caps_toggle";
          };
          "type:touchpad" = {
            dwt = "enabled";
            tap = "enabled";
            middle_emulation = "enabled";
            natural_scroll = "enabled";
          };
        };
        output = {
          "eDP-1" = {
            scale = "1.5";
          };
        };
        fonts = {
          names = ["Iosevka Fixed" "FontAwesome6Free"];
          size = 9.0;
        };
        bars = [];

        workspaceAutoBackAndForth = true;
        bindkeysToCode = true;
        keybindings = mkOptionDefault {
          "Mod4+Shift+a" = "exec shikanectl reload";
          "Mod4+Shift+e" = ''mode "${logoutMode}"'';
          "Mod4+i" = "exec emacsclient --create-frame";
          "Mod4+Control+l" = "exec ${lock}";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 1.2";
          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.2";
          "XF86MonBrightnessUp" = "exec light -A 5";
          "XF86MonBrightnessDown" = "exec light -U 5";
          "XF86AudioPlay" = "exec --no-startup-id playerctl play-pause";
          "XF86AudioPause" = "exec --no-startup-id playerctl play-pause";
          "XF86AudioPrev" = "exec --no-startup-id playerctl previous";
          "XF86AudioNext" = "exec --no-startup-id playerctl next";
        };

        modes = mkOptionDefault {
          "${logoutMode}" = {
            "l" = "exec --no-startup-id swaymsg exit, mode default";
            "s" = "exec --no-startup-id systemctl suspend, mode default";
            "p" = "exec --no-startup-id systemctl poweroff, mode default";
            "r" = "exec --no-startup-id systemctl reboot, mode default";
            "Escape" = "mode default";
            "Return" = "mode default";
          };
        };

        menu = "fuzzel --list-executables-in-path";

        startup = [
          {command = "shikane";}
          {command = "waybar";}
          {
            command = "swaybg --image ~/.wallpaper --mode fill";
            always = true;
          }
          {command = "swayidle -w idlehint 1 before-sleep \"${lock}\"";}
        ];
      };

      extraConfig = ''
        bindswitch --reload --locked lid:off output eDP-1 enable;
        bindswitch --reload --locked lid:on output eDP-1 disable;

        bindgesture swipe:right workspace prev
        bindgesture swipe:left workspace next

        set $rosewater #dc8a78
        set $flamingo #dd7878
        set $pink #ea76cb
        set $mauve #8839ef
        set $red #d20f39
        set $maroon #e64553
        set $peach #fe640b
        set $yellow #df8e1d
        set $green #40a02b
        set $teal #179299
        set $sky #04a5e5
        set $sapphire #209fb5
        set $blue #1e66f5
        set $lavender #7287fd
        set $text #4c4f69
        set $subtext1 #5c5f77
        set $subtext0 #6c6f85
        set $overlay2 #7c7f93
        set $overlay1 #8c8fa1
        set $overlay0 #9ca0b0
        set $surface2 #acb0be
        set $surface1 #bcc0cc
        set $surface0 #ccd0da
        set $base #eff1f5
        set $mantle #e6e9ef
        set $crust #dce0e8

        # target                 title     bg        text   indicator  border
        client.focused           $lavender $lavender $base  $rosewater $lavender
        client.focused_inactive  $overlay0 $base     $text  $rosewater $overlay0
        client.unfocused         $overlay0 $base     $text  $rosewater $overlay0
        client.urgent            $peach    $base     $peach $overlay0  $peach
        client.placeholder       $overlay0 $base     $text  $overlay0  $overlay0
        client.background        $base

        smart_borders on
        default_border pixel 3
        gaps inner 5
        gaps outer 3
      '';
    };

    programs = {
      fuzzel.enable = true;
      swaylock.enable = true;
      waybar = {
        enable = true;
      };
    };

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };

  # FIXME: belongs elsewhere
  services = {
    logind = {
      lidSwitch = "suspend";
      lidSwitchExternalPower = "ignore";
      extraConfig = ''
        IdleAction=suspend
        IdleActionSec=10min
      '';
    };
    upower.enable = true;
  };
}
