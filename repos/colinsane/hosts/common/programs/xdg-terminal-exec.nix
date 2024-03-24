{ pkgs, ... }:
{
  sane.programs.xdg-terminal-exec = {
    packageUnwrapped = pkgs.xdg-terminal-exec.overrideAttrs (upstream: {
      # fix for <https://github.com/Vladimir-csp/xdg-terminal-exec/issues/50>
      postPatch = (upstream.postPatch or "") + ''
        sed '2i\
        unset TERMINAL\
        ' -i xdg-terminal-exec
      '';

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
        })
      ];
    });
    sandbox.enable = false;  # xdg-terminal-exec is a launcher for $TERM
  };
}
