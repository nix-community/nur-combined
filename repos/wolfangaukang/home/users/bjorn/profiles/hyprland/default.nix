{ pkgs
, lib
, config
, osConfig
, inputs
, ...
}:

let
  inherit (pkgs) nwg-look nordic pulsemixer rofiwl-custom waybar;
  commands = import "${inputs.self}/home/users/bjorn/settings/wm-commands.nix" { inherit pkgs config lib; };

  mainMod = "SUPER";

in
{
  home.packages = [
    # Modding
    nwg-look

    # https://sourcegraph.com/github.com/Misterio77/nix-config@9ad4c4f6792e10c4cb5076353250344398bdbfa7/-/blob/home/misterio/features/desktop/common/default.nix
    # GTK Theme
    nordic

    pulsemixer
  ];
  gtk = {
    enable = true;
    font.name = "Fira Sans 8";
    gtk2.extraConfig = "gtk-application-prefer-dark-theme=1";
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  programs = {
    rofi = {
      enable = true;
      package = rofiwl-custom;
      theme = "Arc-Dark";
    };
    swaylock = {
      enable = true;
      settings = {
        daemonize = true;
        ignore-empty-password = true;
        indicator-caps-lock = true;
        scaling = "fill";
        image = "${config.home.homeDirectory}/.lock.jpg";
      };
    };
    waybar = {
      enable = true;
      package = waybar.override {
        hyprlandSupport = true;
        pipewireSupport = true;
        traySupport = true;
      };
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        output = [
          "eDP-1"
        ];
        modules-left = [ "wlr/taskbar" ];
        modules-center = [ "clock" ];
        # https://sourcegraph.com/github.com/nix-community/home-manager@b787726a8413e11b074cde42704b4af32d95545c/-/blob/tests/modules/programs/waybar/settings-complex.nix?L9:14-9:20
        modules-right = [ "idle_inhibitor" "tray" "wireplumber" "backlight" "network" "bluetooth" "battery" ];
        # Modules
        clock = {
          interval = 30;
          format = "{:%a %d %b %Y %H:%M}";
          calendar = {
            mode = "month";
            weeks-pos = "left";
            on-scroll = "1";
          };
        };
        idle_inhibitor = {
          "format" = "{icon}";
          "format-icons" = {
            "activated" = "";
            "deactivated" = "";
          };
        };
        wireplumber = {
          "format" = "  {volume}%";
          "format-muted" = "";
          "on-click" = "${commands.volumeMute}";
        };
        backlight."format" = "  {percent}%";
        battery = {
          "format" = "  {capacity}%";
          "states" = {
            "warning" = "20";
            "critical" = "7";
          };
        };
        bluetooth = {
          "format" = "   {status} ";
          "format-disabled" = "";
          "format-connected" = "   {device_alias} ";
          "format-connected-battery" = "   {device_alias} {device_battery_percentage}% ";
          "on-click" = "${lib.getExe commands.bluetoothToggle}";
        };
        network = {
          "format-wifi" = "  {essid} ({signalStrength}%)";
          "format-ethernet" = "  {ifname}";
          "format-disconnected" = "";
        };
      };
    };
  };
  # TODO: Kanshi https://sourcegraph.com/github.com/nix-community/home-manager@a561ad6ab38578c812cc9af3b04f2cc60ebf48c9/-/blob/tests/modules/services/kanshi/basic-configuration.nix?L3:14-3:20
  # TODO: Customize Fnott
  services = {
    kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";
    };
    fnott.enable = true;
  };
  wayland.windowManager.hyprland = {
    enable = osConfig.programs.hyprland.enable;
    settings = {
      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORMTHEME,qt5ct # change to qt6ct if you have that"
        "GTK_THEME,Nord"
      ];
      input = {
        kb_layout = "colemak-bs_cl";
        kb_variant = "colemak,";
        kb_options = "compose:ralt";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
        sensitivity = 0;
      };
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
      };
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };
      "exec-once" = [
        "${commands.bar}"
        "${commands.wallpaper}"
      ];
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
        ];
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      master.new_is_master = true;
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };
      windowrulev2 = [
        "float,class:^(zenity)$,title:^(Choose a Firefox profile)$"
        "float,class:^(firefox)$,title:^(Picture-in-Picture)$"
        "suppressevent maximize, class:.*"
      ];
      bind = [
        # Exec binds
        "CTRLALT, Delete, exec, ${commands.powerMenu}"
        "${mainMod} CTRLALT, Delete, exec, exit"
        "${mainMod}, space, exec, ${commands.menu}"
        "${mainMod}, T, exec, ${commands.terminal}"
        "${mainMod}, L, exec, ${commands.lock}"
        "${mainMod}, S, exec, ${commands.systemdMenu}"
        "${mainMod}, B, exec, ${commands.bluetoothMgmt}"
        "${mainMod}, K, exec, ${commands.calc}"
        "${mainMod}, G, exec, ${commands.top}"
        ", Print, exec, ${commands.screenshot "save" "screen"}"
        "ALT, Print, exec, ${commands.screenshot "save" "window"}"
        "SHIFT, Print, exec, ${commands.screenshot "save" "area"}"
        "CTRL, Print, exec, ${commands.screenshot "copy" "screen"}"
        "CTRLALT, Print, exec, ${commands.screenshot "copy" "window"}"
        "CTRLSHIFT, Print, exec, ${commands.screenshot "copy" "area"}"

        # Tiles
        "ALT, Tab, cyclenext"
        "SHIFTALT, Tab, cyclenext, prev"
        "${mainMod}, up, movefocus, u"
        "${mainMod}, down, movefocus, d"
        "${mainMod}, left, movefocus, l"
        "${mainMod}, right, movefocus, r"
        "${mainMod} ALT, up, movewindow, u"
        "${mainMod} ALT, down, movewindow, d"
        "${mainMod} ALT, left, movewindow, l"
        "${mainMod} ALT, right, movewindow, r"
        "${mainMod}, F, fullscreen, 1"
        "${mainMod}, U, togglefloating"
        "${mainMod}, Q, killactive"

        # Workspace
        "${mainMod} CTRL, 1, workspace, 1"
        "${mainMod} CTRL, 2, workspace, 2"
        "${mainMod} CTRL, 3, workspace, 3"
        "${mainMod} CTRL, 4, workspace, 4"
        "${mainMod} CTRL, 5, workspace, 5"
        "${mainMod} CTRL, 6, workspace, 6"
        "${mainMod} CTRL, 7, workspace, 7"
        "${mainMod} CTRL, 8, workspace, 8"
        "${mainMod} CTRL, 9, workspace, 9"
        "${mainMod} CTRL, 0, workspace, 10"
        "${mainMod} CTRL, left, workspace, e-1"
        "${mainMod} CTRL, right, workspace, e+1"

        # Move tile to another workspace
        "${mainMod} SHIFT, 1, movetoworkspace, 1"
        "${mainMod} SHIFT, 2, movetoworkspace, 2"
        "${mainMod} SHIFT, 3, movetoworkspace, 3"
        "${mainMod} SHIFT, 4, movetoworkspace, 4"
        "${mainMod} SHIFT, 5, movetoworkspace, 5"
        "${mainMod} SHIFT, 6, movetoworkspace, 6"
        "${mainMod} SHIFT, 7, movetoworkspace, 7"
        "${mainMod} SHIFT, 8, movetoworkspace, 8"
        "${mainMod} SHIFT, 9, movetoworkspace, 9"
        "${mainMod} SHIFT, 0, movetoworkspace, 10"
        "${mainMod} SHIFT, left, movetoworkspace, e-1"
        "${mainMod} SHIFT, right, movetoworkspace, e+1"

        ## TODO: Consider
        # https://www.reddit.com/r/hyprland/comments/xaujb9/a_couple_questions_about_hyprland/
        #"${mainMod}, P, pseudo, # dwindle"
        #"${mainMod}, J, togglesplit, # dwindle"
        #"${mainMod}, left, movefocus, l"
        #"${mainMod}, right, movefocus, r"
        #"${mainMod}, up, movefocus, u"
        #"${mainMod}, down, movefocus, d"

        ## Scroll workspace bind
        #"${mainMod} SHIFT, mouse_down, workspace, e+1"
        #"${mainMod} SHIFT, mouse_up, workspace, e-1"

        # ... Special workspace binds?
        # https://www.reddit.com/r/hyprland/comments/18nt7qg/special_workspace_usage/
        #"${mainMod}, S, togglespecialworkspace, magic"
        #"${mainMod} SHIFT, S, movetoworkspace, special:magic"
      ];
      bindm = [
        "${mainMod}, mouse:272, movewindow"
        "${mainMod}, mouse:273, resizewindow"
      ];
    };
  };
}
