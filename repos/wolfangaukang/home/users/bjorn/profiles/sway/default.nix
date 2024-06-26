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

  mainMod = "Mod4";

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
    fnott.enable = true;
    kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";
    };
    swayidle = {
      enable = true;
      events = [
        { event = "before-sleep"; command = "${commands.lock}"; }
        { event = "lock"; command = "${commands.lock}"; }
      ];
      timeouts = [
        { timeout = 300; command = "${commands.lock}"; }
        { timeout = 600; command = "systemctl suspend"; }
      ];
    };
  };
  wayland.windowManager.sway = {
    enable = osConfig.programs.sway.enable;
    checkConfig = false;
    config = {
      modifier = mainMod;
      terminal = commands.terminal;
      menu = commands.menu;
      bars = [{
        command = lib.getExe waybar;
      }];
      gaps = {
        inner = 10;
        smartGaps = true;
        smartBorders = "on";
      };
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in {
        "Ctrl+Alt+Delete" = "exec ${commands.powerMenu}";
        #"${modifier}+Ctrl+Alt+Delete" = "exit"
        "${modifier}+Space" = "exec ${commands.menu}";
        "${modifier}+t" = "exec ${commands.terminal}";
        "${modifier}+l" = "exec --no-startup-id ${commands.lock}";
        "${modifier}+s" = "exec ${commands.systemdMenu}";
        "${modifier}+b" = "exec ${commands.bluetoothMgmt}";
        "${modifier}+k" = "exec ${commands.calc}";
        "${modifier}+g" = "exec ${commands.top}";
        "Print" = "exec --no-startup-id --no-startup-id ${commands.screenshot "save" "screen"}";
        "Alt+Print" = "exec --no-startup-id ${commands.screenshot "save" "window"}";
        "Shift+Print" = "exec --no-startup-id ${commands.screenshot "save" "area"}";
        "Ctrl+Print" = "exec --no-startup-id ${commands.screenshot "copy" "screen"}";
        "Ctrl+Alt+Print" = "exec --no-startup-id ${commands.screenshot "copy" "window"}";
        "Ctrl+Shift+Print" = "exec --no-startup-id ${commands.screenshot "copy" "area"}";

        ## Tiles
        #"ALT, Tab, cyclenext"
        #"SHIFTALT, Tab, cyclenext, prev"
        "${modifier}+Up" = "focus up";
        "${modifier}+Down" = "focus down";
        "${modifier}+Left" = "focus left";
        "${modifier}+Right" = "focus right";
        "${modifier}+Alt+Up" = "move up";
        "${modifier}+Alt+Down" = "move down";
        "${modifier}+Alt+Left" = "move left";
        "${modifier}+Alt+Right" = "move right";
        "${modifier}+f" = "floating toggle";
        "${modifier}+q" = "kill";
        # Splitting
        "${modifier}+h" = "splith";
        "${modifier}+v" = "splitv";
        # Layout mode
        "${modifier}+Alt+l" = "layout stacking";
        "${modifier}+Alt+u" = "layout tabbed";
        "${modifier}+Alt+y" = "layout toggle split";
        #"${modifier}, U, togglefloating"


        ## Workspace
        "${modifier}+Ctrl+1" = "workspace number 1";
        "${modifier}+Ctrl+2" = "workspace number 2";
        "${modifier}+Ctrl+3" = "workspace number 3";
        "${modifier}+Ctrl+4" = "workspace number 4";
        "${modifier}+Ctrl+5" = "workspace number 5";
        "${modifier}+Ctrl+6" = "workspace number 6";
        "${modifier}+Ctrl+7" = "workspace number 7";
        "${modifier}+Ctrl+8" = "workspace number 8";
        "${modifier}+Ctrl+9" = "workspace number 9";
        "${modifier}+Ctrl+0" = "workspace number 10";
        "${modifier}+Ctrl+left" = "workspace prev";
        "${modifier}+Ctrl+right" = "workspace next";

        ## Move tile to another workspace
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";
        "${modifier}+Shift+left" = "move container to workspace prev";
        "${modifier}+Shift+right" = "move container to workspace next";

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
      #];
      };
      output = {
        "eDP-1" = {
          bg = "${config.home.homeDirectory}/.wallpaper.jpg fill";
        };
      };
    };
    extraConfig = ''
      for_window [title="Choose a Firefox profile"] floating enable
      for_window [title="Picture-in-Picture"] floating enable
    '';
    wrapperFeatures.gtk = true;
    #settings = {
      #env = [
        #"XCURSOR_SIZE,24"
        #"QT_QPA_PLATFORMTHEME,qt5ct # change to qt6ct if you have that"
        #"GTK_THEME,Nord"
      #];
      #input = {
        #follow_mouse = 1;
        #sensitivity = 0;
      #};
      #general = {
        #gaps_in = 5;
        #gaps_out = 20;
        #border_size = 2;
        #"col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        #"col.inactive_border" = "rgba(595959aa)";
      #};
      #decoration = {
        #rounding = 10;
        #blur = {
          #enabled = true;
          #size = 3;
          #passes = 1;
          #vibrancy = 0.1696;
        #};
        #drop_shadow = true;
        #shadow_range = 4;
        #shadow_render_power = 3;
        #"col.shadow" = "rgba(1a1a1aee)";
      #};
      #animations = {
        #enabled = true;
        #bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        #animation = [
          #"windows, 1, 7, myBezier"
          #"windowsOut, 1, 7, default, popin 80%"
          #"border, 1, 10, default"
          #"borderangle, 1, 8, default"
          #"fade, 1, 7, default"
        #];
      #};
      #dwindle = {
        #pseudotile = true;
        #preserve_split = true;
      #};
      #master.new_is_master = true;
      #device = {
        #name = "epic-mouse-v1";
        #sensitivity = -0.5;
      #};
      #windowrulev2 = [
        #"suppressevent maximize, class:.*"
      #];
#      
    #};
  };
}
