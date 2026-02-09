{
  lib,
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType2 rec {
  pname = "pot";
  version = "3.0.7";
  src = fetchurl {
    url = "https://github.com/pot-app/pot-desktop/releases/download/${version}/pot_${version}_amd64.AppImage";
    hash = "sha256-ipI14zTZEp7g0kr9UEEN7/N7e/kEZv/f0wOAhH606FE=";
  };
  meta = {
    description = ''
      🌈一个跨平台的划词翻译和OCR软件 | A cross-platform software for text translation and recognition. 
    '';
    homepage = "https://pot-app.com/";
    mainProgram = "pot";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
