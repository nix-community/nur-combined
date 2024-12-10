{ static-nix-shell, copyDesktopItems, makeDesktopItem }:
static-nix-shell.mkBash {
  pname = "sane-color-picker";
  srcRoot = ./.;
  pkgs = [ "gnugrep" "wl-clipboard" "zenity" ];
  nativeBuildInputs = [
    copyDesktopItems
  ];
  desktopItems = [
    (makeDesktopItem {
      name = "sane-color-picker";
      exec = "sane-color-picker";
      desktopName = "Color Picker";
    })
  ];
}

