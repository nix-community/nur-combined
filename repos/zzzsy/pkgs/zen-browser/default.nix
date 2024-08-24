{
  lib,
  appimageTools,
  fetchurl,
  variant ? "specific",
}:
let
  pname = "zen-browser";
  version = "1.0.0-a.28";
  hashes = {
    specific = "sha256-S49M3QVpjQ36+f4xeC13XXn11IlzHmTvfIZkTS/YOF4=";
    generic = "sha256-5Sq1UwHf9QdICwxIi3CU3M6cgyIomIAhse5H66yivxA=";
  };

  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-${variant}.AppImage";
    hash = lib.getAttr variant hashes;
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

  meta = with lib; {
    description = "Experience tranquillity while browsing the web without people tracking you!";
    homepage = "https://zen-browser.app";
    license = licenses.mpl20;
    platforms = [ "x86_64-linux" ];
  };

}
