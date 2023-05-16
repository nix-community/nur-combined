{ wine, wrapWine, makeDesktopItem, fetchurl, unrar, symlinkJoin, ... }:
# FIXME: Can't hear that lovely music and the sound effects
let
  wine = wine.override {
    alsaSupport = true;
    faudioSupport = true;
    wineRelease = "staging";
    wineBuild = "wine32";
  };
  rarFile = fetchurl {
    url = "https://archive.org/download/SpaceCadet_Plus95/Space_Cadet.rar";
    sha256 = "3cc5dfd914c2ac41b03f006c7ccbb59d6f9e4c32ecfd1906e718c8e47f130f4a";
  };
  bin = wrapWine {
    name = "pinball";
    executable = "$WINEPREFIX/drive_c/PINBALL.exe";
    firstrunScript = ''
      pushd "$WINEPREFIX/drive_c"
        ${unrar}/bin/unrar x ${rarFile}
      popd
    '';
  };
desktop = makeDesktopItem {
  name = "Pinball";
  desktopName = "Pinbal - Space Cadet";
  icon = fetchurl {
    url = "https://www.chip.de/ii/1/8/8/0/2/9/2/3/028c4582789e6c07.jpg";
    sha256 = "1lwsnsp4hxwqwprjidgmxksaz13ib98w34r6nxkhcip1z0bk1ilz";
  };
  type = "Application";
  exec = "${bin}/bin/pinball";
};
in symlinkJoin {
  name = "pinball-app";
  paths = [
    bin
    desktop
  ];
}
