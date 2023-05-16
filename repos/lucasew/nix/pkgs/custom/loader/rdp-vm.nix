{ writeShellScriptBin
, makeDesktopItem
, rdesktop
, symlinkJoin
, fechurl
, ...
}:
let
  bin = writeShellScriptBin "rdp-w10" ''
    ${rdesktop}/bin/rdesktop -u user -p 123 192.168.56.101 || notify-send "A vm tá rodando?"
  '';
  desktop = makeDesktopItem {
    name = "rdp-w10";
    desktopName = "Conectar na VM de Windows 10";
    icon = fetchurl {
      url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/windows.png";
      sha256 = "1s9b1wnfl2hjsy2l03x7wwqam86qrsaflpyliyknj63z6i3h4k1j";
    };
    exec = "${bin}/bin/rdp-w10";
  };
in symlinkJoin {
  name = "rdp-w10";
  paths = [
    bin
    desktop
  ];
}
