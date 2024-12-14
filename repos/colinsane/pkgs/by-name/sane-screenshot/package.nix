{ static-nix-shell, copyDesktopItems, makeDesktopItem }:
static-nix-shell.mkBash {
  pname = "sane-screenshot";
  srcRoot = ./.;
  pkgs = [ "grim" "jq" "libnotify" "slurp" "swappy" "sway" "util-linux" "wl-clipboard" ];
  nativeBuildInputs = [
    copyDesktopItems
  ];
  desktopItems = [
    (makeDesktopItem {
      name = "sane-screenshot";
      exec = "sane-screenshot";
      desktopName = "Interactive Screenshotter";
    })
  ];
}
