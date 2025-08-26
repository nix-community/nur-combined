{
  lib,
  appimageTools,
  sources,
}:

let
  inherit (sources.moe-koe-music) version pname src;
  # both extractType1 and extractType2 have the same behaviour as extract now
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/moekoemusic.desktop \
      $out/share/applications/${pname}.desktop
    install -Dm644 ${appimageContents}/resources/icons/linux_512x512.png \
      $out/share/icons/hicolor/512x512/apps/${pname}.png
    install -Dm644 ${appimageContents}/resources/icons/linux_256x256.png \
      $out/share/icons/hicolor/256x256/apps/${pname}.png
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}' \
      --replace-fail 'Icon=moekoemusic' 'Icon=${pname}'
  '';

  meta = with lib; {
    description = "An open-source, concise, and aesthetically pleasing third-party client for KuGou";
    homepage = "https://github.com/iAJue/MoeKoeMusic";
    license = licenses.gpl2;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [
      yisuidenghua
      yinfeng
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "MoeKoeMusic";
  };
}
