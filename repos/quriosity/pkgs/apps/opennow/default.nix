{ lib, appimageTools, fetchurl, makeDesktopItem, nix-update-script, libgpg-error }:

let
  pname = "opennow";
  version = "1.0.3";

  src = fetchurl {
    url = "https://github.com/OpenCloudGaming/OpenNOW/releases/download/v${version}/OpenNOW-Qt-${version}-Linux-x64.AppImage";
    hash = "sha256-xG1Wzyk89VMhsA4Pc32e9nmbceq6wGBRhgsiK2j5EDo=";
  };

  appimageContents = appimageTools.extract {
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

  extraPkgs = _: [ libgpg-error ];

  extraInstallCommands = ''
    install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop

    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/io.github.opencloudgaming.OpenNOW.png \
      $out/share/icons/hicolor/512x512/apps/${pname}.png
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
