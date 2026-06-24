{
  copyDesktopItems,
  makeDesktopItem,
  rofi,
  sane-open,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "rofi-kagi";
  srcRoot = ./.;
  pkgs = {
    inherit
      rofi
      sane-open
    ;
  };
  nativeBuildInputs = [
    copyDesktopItems
  ];
  desktopItems = [
    (makeDesktopItem {
      name = "rofi-kagi";
      exec = "rofi-kagi";
      # rofi macro to do a kagi search
      desktopName = "Kagi Launcher";
    })
  ];
  meta = {
    description = "rofi prompt which runs `kagi search` with the entered query";
    mainProgram = "rofi-kagi";
  };
}
