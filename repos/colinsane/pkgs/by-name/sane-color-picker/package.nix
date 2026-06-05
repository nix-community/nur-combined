{
  copyDesktopItems,
  gnugrep,
  makeDesktopItem,
  static-nix-shell,
  wl-clipboard-rs,
  zenity,
}:
static-nix-shell.mkBash {
  pname = "sane-color-picker";
  srcRoot = ./.;
  pkgs = {
    inherit
      gnugrep
      wl-clipboard-rs
      zenity
    ;
  };
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

