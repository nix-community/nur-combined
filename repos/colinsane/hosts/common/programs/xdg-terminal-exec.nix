{ pkgs, ... }:
{
  sane.programs.xdg-terminal-exec = {
    # give the package a .desktop item.
    # this way anyone can launch a terminal via the xdg-desktop-portal.
    packageUnwrapped = pkgs.xdg-terminal-exec.overrideAttrs (upstream: {
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
        pkgs.copyDesktopItems
      ];
      desktopItems = (upstream.desktopItems or []) ++ [
        (pkgs.makeDesktopItem {
          name = "xdg-terminal-exec";
          exec = "xdg-terminal-exec";
          desktopName = "Default Terminal";
        })
      ];
    });
    sandbox.enable = false;  # xdg-terminal-exec is a launcher for $TERM
  };
}
