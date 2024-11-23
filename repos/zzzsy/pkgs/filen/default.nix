{
  appimageTools,
  fetchurl,
}:
let
  pname = "Filen";
  version = "0.0.0";
  src = fetchurl {
    url = "https://cdn.filen.io/@filen/desktop/release/latest/Filen_linux_x86_64.AppImage";
    hash = "sha256-2tBssJ6X1BI6yMGu0CQW5VmMY9i28LXI20EZfNbL8JY=";
  };

  extracted = appimageTools.extract {
    inherit pname version src;
  };

in

appimageTools.wrapType2 {
  inherit pname version src;
  extraInstallCommands = ''
    install -Dm 644 ${extracted}/@filendesktop.desktop $out/share/applications/@filendesktop.desktop
    install -Dm 644 {${extracted}/usr/,$out}/share/icons/hicolor/128x128/apps/@filendesktop.png
  '';
}
