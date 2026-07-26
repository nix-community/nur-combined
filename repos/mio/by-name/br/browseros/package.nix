{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "browseros";
  version = "0.48.1";

  src = fetchurl {
    url = "https://files.browseros.com/download/BrowserOS.AppImage";
    hash = "sha256-j17ERzRxTx/0OaKtSjp02DXi132Rfz9qse5uI7auu7s=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/usr/share/applications/browseros.desktop \
      $out/share/applications/${pname}.desktop

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail "/opt/browseros/browseros" "${pname}"

    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/256x256/apps/browseros.png \
      $out/share/icons/hicolor/256x256/apps/${pname}.png
  '';

  meta = {
    description = "BrowserOS AI-driven web browser";
    homepage = "https://BrowserOS.com";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "browseros";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
