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

    # TODO: place in global home conf
    services.dunst.enable = true;

    home.packages = builtins.attrValues {
      inherit
        (pkgs)
        ansel
        chromium # some websites only work there :(
        zotero
        ;

      inherit
        (pkgs.packages)
        spot
        ;
    };

    wayland.windowManager.sway = {
      enable = true;
      swaynag.enable = true;
      wrapperFeatures.gtk = true;
      config = {
        modifier = "Mod4";
        input = {
          "type:keyboard" = {
            xkb_layout = "fr";
            xkb_variant = "us";
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
        bars = [
          {
            mode = "dock";
            hiddenState = "hide";
            position = "top";
            workspaceButtons = true;
            workspaceNumbers = true;
            statusCommand = "${pkgs.i3status}/bin/i3status";
            fonts = {
              names = ["Iosevka Fixed" "FontAwesome6Free"];
              size = 9.0;
            };
            trayOutput = "primary";
            colors = {
              background = "#000000";
              statusline = "#ffffff";
              separator = "#666666";
              focusedWorkspace = {
                border = "#4c7899";
                background = "#285577";
                text = "#ffffff";
              };
              activeWorkspace = {
                border = "#333333";
                background = "#5f676a";
                text = "#ffffff";
              };
              inactiveWorkspace = {
                border = "#333333";
                background = "#222222";
                text = "#888888";
              };
              urgentWorkspace = {
                border = "#2f343a";
                background = "#900000";
                text = "#ffffff";
              };
              bindingMode = {
                border = "#2f343a";
                background = "#900000";
                text = "#ffffff";
              };
            };
          }
        ];

        keybindings = mkOptionDefault {
          "Mod4+i" = "exec emacsclient --create-frame";
        };
      };
    };
    programs = {
      fuzzel.enable = true;
      swaylock.enable = true;
      waybar = {
        enable = true;
      };
    };
  };
}
