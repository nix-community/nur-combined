{ lib, appimageTools, fetchurl, makeDesktopItem, nix-update-script }:

let
  pname = "opennow";
  version = "0.5.3";

  src = fetchurl {
    url = "https://github.com/OpenCloudGaming/OpenNOW/releases/download/v${version}/OpenNOW-v${version}-linux-x86_64.AppImage";
    hash = "sha256-uiGy5f9kWidMby7/DBt89jarGFH7eits9XfvtQ5s6rQ=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} --no-sandbox %U";
    icon = pname;
    desktopName = "OpenNow";
    comment = "Electron-based OpenNOW stable client";
    categories = [ "Game" ];
    startupNotify = true;
    startupWMClass = "OpenNOW";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop

    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/2048x2048/apps/opennow-stable.png \
      $out/share/icons/hicolor/256x256/apps/${pname}.png
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Custom GeForce Now Client Named OpenNOW";
    homepage = "https://github.com/OpenCloudGaming/OpenNOW";
    license = licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "opennow";
  };
}
