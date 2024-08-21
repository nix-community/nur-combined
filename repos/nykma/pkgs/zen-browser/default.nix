{ lib, appimageTools, fetchurl }:
let
  pname = "zen-browser";
  version = "1.0.0-a.26";
  sha256 = "sha256-F2yC3tvRJ0HNPAa8lS6k58Z5O1YH/4aNNW+aZZJYmY0=";
  url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-specific.AppImage";
  src = fetchurl {
    inherit url sha256;
  };
  extracted = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
  install -m 444 -D ${extracted}/zen.desktop $out/share/applications/zen.desktop
  install -m 444 -D ${extracted}/usr/share/icons/hicolor/128x128/apps/zen.png $out/share/icons/hicolor/128x128/apps/zen.png
  substituteInPlace $out/share/applications/zen.desktop --replace 'Exec=zen' 'Exec=${pname}'
  '';

  meta = with lib; {
    description = "Experience tranquillity while browsing the web without people tracking you!";
    homepage = "https://zen-browser.app";
    license = licenses.mpl20;
    platforms = [ "x86_64-linux" ];
  };
}
