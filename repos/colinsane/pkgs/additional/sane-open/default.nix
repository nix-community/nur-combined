{ static-nix-shell
, copyDesktopItems
, makeDesktopItem
}:
static-nix-shell.mkBash {
  pname = "sane-open";
  srcRoot = ./.;
  pkgs = [ "glib" "jq" "procps" "sway" "util-linux" "xdg-utils" ];
  nativeBuildInputs = [
    copyDesktopItems
  ];
  desktopItems = [
    (makeDesktopItem {
      name = "sane-open-desktop";
      exec = "sane-open --desktop-file %f";
      desktopName = ".desktop launcher";
      mimeTypes = [ "application/x-desktop" ];
      noDisplay = true;
    })
  ];
}
