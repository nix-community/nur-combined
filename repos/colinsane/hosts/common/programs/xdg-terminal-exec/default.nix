{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.xdg-terminal-exec;
in
{
  sane.programs.xdg-terminal-exec = {
    configOption = with lib; mkOption {
      type = types.submodule {
        options = {
          terminal = mkOption {
            type = types.str;
            default = "wezterm";
          };
        };
      };
    };

    # TODO: don't `overrideAttrs`, but `symlinkJoin` with the new .desktop item
    packageUnwrapped = pkgs.xdg-terminal-exec.overrideAttrs (upstream: {
      # give the package a .desktop item.
      # this way anyone can launch a terminal via the xdg-desktop-portal.
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
        pkgs.copyDesktopItems
      ];
      desktopItems = (upstream.desktopItems or []) ++ [
        (pkgs.makeDesktopItem {
          name = "xdg-terminal-exec";
          exec = "xdg-terminal-exec";
          desktopName = "Default Terminal";
          noDisplay = true;
        })
      ];
    });
    sandbox.enable = false;  # xdg-terminal-exec is a launcher for $TERM

    suggestedPrograms = [
      cfg.config.terminal
    ];

    env.TERMINAL = lib.mkDefault cfg.config.terminal;
  };
}
