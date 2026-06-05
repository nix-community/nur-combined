{
  copyDesktopItems,
  glib,
  jq,
  makeDesktopItem,
  mimeo-query-desktop,
  procps,
  sane-open,
  static-nix-shell,
  sway,
  util-linux,
  wl-clipboard-rs,
}:
static-nix-shell.mkBash {
  pname = "sane-open";
  srcRoot = ./.;
  pkgs = {
    inherit
      glib
      jq
      mimeo-query-desktop
      procps
      sway
      util-linux
    ;
  };
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
    pkgs = {
      inherit
        sane-open
        wl-clipboard-rs
      ;
    };
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
