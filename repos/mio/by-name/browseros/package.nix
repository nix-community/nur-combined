{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "browseros";
  version = "0.44.0.1";

  src = fetchurl {
    url = "https://github.com/browseros-ai/BrowserOS/releases/download/v${version}/BrowserOS_v${version}_x64.AppImage";
    hash = "sha256-ALnyVMnexYy48br9qbWaEbOZm7hJR9g39a9nYzbWXwo=";
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
