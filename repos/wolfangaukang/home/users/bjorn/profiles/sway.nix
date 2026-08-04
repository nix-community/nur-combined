{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:

let
  inherit (pkgs) waybar;
  inherit (builtins) listToAttrs map;
  inherit (lib.strings) toLower;
  inherit (lib.trivial) mod;
  commands = import "${inputs.self}/home/users/bjorn/settings/wm-commands.nix" {
    inherit pkgs config lib;
  };
  mainMod = "Mod4";

in
{
  imports = [ ./wayland.nix ];
  programs.waybar.package = waybar.override {
    pipewireSupport = true;
    traySupport = true;
  };
  wayland.windowManager.sway = {
    enable = osConfig.programs.sway.enable;
    checkConfig = false;
    config = {
      input."12951:6505:ZSA_Technology_Labs_Moonlander_Mark_I" = {
        xkb_layout = "us";
        xkb_options = "compose:ralt";
      };
      modifier = mainMod;
      terminal = commands.terminal;
      defaultWorkspace = "workspace number 1";
      menu = commands.menu;
      bars = [
        {
          command = lib.getExe waybar;
        }
      ];
      gaps = {
        inner = 10;
        smartGaps = true;
        smartBorders = "on";
      };
      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;

          splitting = listToAttrs (
            map
              (dir: {
                name = "${modifier}+${dir}";
                value = "split${dir}";
              })
              [
                "h"
                "v"
              ]
          );

          # Workspaces
          workspaces = lib.lists.range 1 10;
          changeWorkspaces = listToAttrs (
            map (number: {
              name = "${modifier}+Ctrl+${toString (lib.trivial.mod number 10)}";
              value = "workspace number ${toString number}";
            }) workspaces
          );
          moveWorkspaces = listToAttrs (
            map (number: {
              name = "${modifier}+Shift+${toString (lib.trivial.mod number 10)}";
              value = "move container to workspace number ${toString number}";
            }) workspaces
          );
          horizontalDirections = [
            "left"
            "right"
          ];
          getSwayDirection = direction: if direction == "left" then "prev" else "next";
          moveWorkspaceHorizontally = listToAttrs (
            map (direction: {
              name = "${modifier}+Ctrl+${direction}";
              value = "workspace ${getSwayDirection direction}";
            }) horizontalDirections
          );
          moveContainerWorkspaceHorizontally = listToAttrs (
            map (direction: {
              name = "${modifier}+Shift+${direction}";
              value = "move container to workspace ${getSwayDirection direction}";
            }) horizontalDirections
          );

          # Tiles
          directions = [
            "Up"
            "Down"
            "Left"
            "Right"
          ];
          focusTiles = listToAttrs (
            map (direction: {
              name = "${modifier}+${direction}";
              value = "focus ${toLower direction}";
            }) directions
          );
          moveTiles = listToAttrs (
            map (direction: {
              name = "${modifier}+Alt+${direction}";
              value = "move ${toLower direction}";
            }) directions
          );
          layouts = listToAttrs (
            map
              (pair: {
                name = "${modifier}+Alt+${pair.key}";
                value = "layout ${pair.type}";
              })
              [
                {
                  key = "l";
                  type = "stacking";
                }
                {
                  key = "u";
                  type = "tabbed";
                }
                {
                  key = "y";
                  type = "toggle split";
                }
              ]
          );

          # Other
          screenshotKeys = [
            {
              key = "";
              type = "screen";
            }
            {
              key = "Alt+";
              type = "window";
            }
            {
              key = "Shift+";
              type = "area";
            }
          ];
          saveScreenshot = listToAttrs (
            map (pair: {
              name = "${pair.key}Print";
              value = "exec --no-startup-id ${commands.screenshot "save" pair.type}";
            }) screenshotKeys
          );
          copyScreenshot = listToAttrs (
            map (pair: {
              name = "Ctrl+${pair.key}Print";
              value = "exec --no-startup-id ${commands.screenshot "copy" pair.type}";
            }) screenshotKeys
          );
          volume = listToAttrs (
            map
              (indicator: {
                name = "XF86Audio${indicator}Volume";
                value = "exec --no-startup-id ${commands.volume} -${if indicator == "Lower" then "d" else "i"} 5";
              })
              [
                "Lower"
                "Raise"
              ]
          );

        in
        changeWorkspaces
        // moveWorkspaces
        // focusTiles
        // moveTiles
        // moveWorkspaceHorizontally
        // moveContainerWorkspaceHorizontally
        // layouts
        // splitting
        // volume
        // saveScreenshot
        // copyScreenshot
        // {
          "Ctrl+Alt+Delete" = "exec ${commands.powerMenu}";
          #"${modifier}+Ctrl+Alt+Delete" = "exit"
          "${modifier}+l" = "exec --no-startup-id ${commands.lock}";
          "${modifier}+r" = "exec ${commands.calc}";
          "${modifier}+i" = "exec ${commands.bluetoothMgmt}";
          "${modifier}+t" = "exec ${commands.terminal}";
          "${modifier}+Shift+b" = "exec --no-startup-id ${commands.kvm.peripherals}";
          "${modifier}+Shift+k" = "exec --no-startup-id ${commands.kvm.screen}";
          "${modifier}+Space" = "exec ${commands.menu}";
          "XF86AudioMute" = "exec --no-startup-id ${commands.volumeMute}";

          ## Tiles
          "${modifier}+f" = "floating toggle";
          "${modifier}+q" = "kill";
        };
      window.titlebar = false;
    };
    extraConfig = ''
      for_window [title="Choose a Firefox profile"] floating enable
      for_window [title="Picture-in-Picture"] floating enable
    '';
    wrapperFeatures.gtk = true;
    xwayland = true;
  };
}
