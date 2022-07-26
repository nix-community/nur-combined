# winetricks vb6run comdlg32.ocx msflxgrd
{ fetchurl, wrapWine, ...}:
let
  source = fetchurl {
    url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/tora.exe";
    sha256 = "19c74735d6cklnjfh7gb4axxjq69h7jsdpaypby9ajqf3wij4yv5";
  };
  bin = wrapWine {
    name = "tora-lp";
    wineFlags = "explorer /desktop=name,1024x768";
    setupScript = ''
      cp ${source} $WINEPREFIX/tora.exe
    '';
    tricks = [
      "vb6run"
      "comdlg32.ocx"
      "msflxgrd"
    ];
    executable = "$WINEPREFIX/tora.exe";
  };
in makeDesktopItem {
  name = "tora";
  desktopName = "TORA";
  icon = "utility";
  exec = "${bin}/bin/tora-lp";
}
