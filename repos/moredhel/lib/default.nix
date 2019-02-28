{ pkgs }:

with pkgs.lib; rec {
  # Add your library functions here
  #
  desktopFile = import ./desktop.nix { inherit pkgs; };
  buildDesktops = xs: listToAttrs (map desktopFile xs);
  test = {
    minimal = {
      package = pkgs.vscode;
      name = "VSCode";
    };
    desktop = {
      name = "test";
      exec = "/my/exec/path";
      icon = "/my/icon/path";
    };
  };
}

