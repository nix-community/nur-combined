{
  copyDesktopItems,
  makeDesktopItem,
  static-nix-shell,
}:
static-nix-shell.mkBash {
  pname = "sane-open";
  srcRoot = ./.;
  pkgs = [
    "glib"
    "jq"
    "procps"
    "sway"
    "util-linux"
    "xdg-utils"
  ];
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

  passthru.clipboard = static-nix-shell.mkBash {
    pname = "sane-open-clipboard";
    srcRoot = ./.;
    pkgs = [
      "sane-open"
      "wl-clipboard"
    ];
    nativeBuildInputs = [
      copyDesktopItems
    ];
    desktopItems = [
      (makeDesktopItem {
        name = "sane-open-clipboard";
        exec = "sane-open-clipboard";
        desktopName = "Open Clipboard Paste";
      })
    ];
  };
}
