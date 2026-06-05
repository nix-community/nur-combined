{
  copyDesktopItems,
  grim,
  jq,
  libnotify,
  makeDesktopItem,
  slurp,
  static-nix-shell,
  swappy,
  sway,
  util-linux,
  wl-clipboard-rs,
}:
static-nix-shell.mkBash {
  pname = "sane-screenshot";
  srcRoot = ./.;
  pkgs = {
    inherit
      grim
      jq
      libnotify
      slurp
      swappy
      sway
      util-linux
      wl-clipboard-rs
      ;
  };
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
