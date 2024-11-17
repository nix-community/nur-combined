{ static-nix-shell, copyDesktopItems, makeDesktopItem }:
static-nix-shell.mkBash {
  pname = "sane-screenshot";
  srcRoot = ./.;
  pkgs = [ "libnotify" "swappy" "sway-contrib.grimshot" "util-linux" "wl-clipboard" ];
  nativeBuildInputs = [
    copyDesktopItems
  ];
  desktopItems = [
    (makeDesktopItem {
      name = "sane-screenshot";
      exec = "sane-screenshot";
      desktopName = "interactive screenshotter";
    })
  ];
}
