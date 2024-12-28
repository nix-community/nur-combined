{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "zen-browser";
  metadata = builtins.fromJSON (builtins.readFile ./metadata.json);
  version = metadata.version;

  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
    hash = metadata.hash;
  };

  extracted = appimageTools.extract {
    inherit pname version src;
  };

in

appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm 644 ${extracted}/zen.desktop $out/share/applications/zen.desktop
    install -Dm 644 {${extracted}/usr/,$out}/share/icons/hicolor/128x128/apps/zen.png
    substituteInPlace $out/share/applications/zen.desktop --replace-fail 'Exec=zen' 'Exec=${pname}'
  '';

  updateScript = ./update.sh;

  meta = with lib; {
    description = "Experience tranquillity while browsing the web without people tracking you!";
    homepage = "https://zen-browser.app";
    license = licenses.mpl20;
    platforms = [ "x86_64-linux" ];
  };

}
