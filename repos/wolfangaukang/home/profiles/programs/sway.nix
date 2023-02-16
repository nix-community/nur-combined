{ config, pkgs, lib, ... }:

let
  xset_capslock = { command = "xset r 66"; always = true; };
in {
  imports = [
    ../common/layouts.nix
    ../common/mako.nix
    ../common/rofi.nix
    ../common/udiskie.nix
    ../common/waybar.nix
  ];

  home.packages = with pkgs; [
    # Fonts
    fira
    noto-fonts
    noto-fonts-cjk

    # CLI
    xorg.xset
  ];

  gtk = {
    enable = true;
    #font = {
    #  name = "Fira Sans 8";
    #};
    gtk2.extraConfig = "gtk-application-prefer-dark-theme=1";
    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    config = {
      input = {
        "*" = {
          xkb_variant = "colemak,";
        };
        "type:keyboard" = {
          xkb_layout = "colemak-bs_cl";
        };
      };
      bars = [{
        command = "waybar";
      }];
      colors = {
        focused = {
          border = "#d34e24";
          background = "#d34e24";
          childBorder = "#d34e24";
          indicator = "#ffff00";
          text = "#ffffff";
        };
        urgent = {
          border = "#ff0000";
          background = "#ff0000";
          childBorder = "#ff0000";
          indicator = "#ffffff";
          text = "#ffffff";
        };
      };
      gaps = {
        inner = 10;
        smartGaps = true; 
        smartBorders = "on";
      };
      keybindings = let
        menu = config.wayland.windowManager.sway.config.menu;
        modifier = config.wayland.windowManager.sway.config.modifier;
        term = config.wayland.windowManager.sway.config.terminal;
        path = "/home/bjorn/Bildujo/$(eval date +\"%F@%T\").png";
        grimshot_common_prefix = "exec --no-startup-id sh -c \"grimshot --notify";
        grimshot_save_screen = "${grimshot_common_prefix} save screen ${path}\"";
        grimshot_save_window = "${grimshot_common_prefix} save window ${path}\"";
        grimshot_save_area = "${grimshot_common_prefix} save area ${path}\"";
        grimshot_copy_screen = "${grimshot_common_prefix} copy screen\"";
        grimshot_copy_window = "${grimshot_common_prefix} copy window\"";
        grimshot_copy_area = "${grimshot_common_prefix} copy area\"";
      in lib.mkOptionDefault {
        "Print" = grimshot_save_screen;
        "Alt+Print" = grimshot_save_window;
        "Shift+Print" = grimshot_save_area;
        "Ctrl+Print" = grimshot_copy_screen;
        "Ctrl+Alt+Print" = grimshot_copy_window;
        "Ctrl+Shift+Print" = grimshot_copy_area;
        "${modifier}+Return" = "exec ${menu}";
        "${modifier}+t" = "exec ${term}";
        "Shift+${modifier}+x" = "exec swaynag -t warning -m 'You pressed the poweroff shortcut. Do you really want to poweroff computer?' -b 'Yes, poweroff' 'systemctl poweroff'";
      };
      menu = "\"rofi -combi-modi drun,ssh -show combi -modi combi\"";
      modifier = "Mod4";
      output = { "*" = { bg = "~/.wallpaper fill"; }; };
      startup = [ xset_capslock ];
      terminal = "kitty";
      window = {
        commands = [ { command = "opacity 0.9"; criteria = { app_id = "kitty"; }; } ];
      };
    };
    wrapperFeatures.gtk = true;
  };
}
