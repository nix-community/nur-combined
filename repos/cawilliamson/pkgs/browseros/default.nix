{ appimageTools
, fetchurl
, lib
, makeDesktopItem
, stdenv
, ...
}:

let
  pname = "browseros";
  version = "0.43.0";
  assetVersion = version; # override when upstream uses a different version in asset filenames (e.g. "0.42.0.1")

  desktopItem = makeDesktopItem {
    name = "${pname}";
    exec = "${pname}";
    icon = "${pname}";
    type = "Application";
    desktopName = "BrowserOS";
    categories = [
      "Network"
      "WebBrowser"
    ];
  };

  src = fetchurl {
    name = "browseros.AppImage";
    sha256 = "sha256-CfpMSc+mo5LI1oIWoi93lCnm7t0CNMvaKfl8AGcywxE=";
    url = "https://github.com/browseros-ai/BrowserOS/releases/download/v${version}/BrowserOS_v${assetVersion}_x64.AppImage";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname src version;

  extraInstallCommands = ''
    mkdir -p $out/share/applications $out/share/icons/hicolor/256x256/apps
    cp ${desktopItem}/share/applications/* $out/share/applications
    cp ${appimageContents}/usr/share/icons/hicolor/256x256/apps/${pname}.png $out/share/icons/hicolor/256x256/apps/${pname}.png
  '';

  meta = {
    homepage = "https://www.browseros.com";
    description = "The Open source agentic browser";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ cawilliamson ];
    mainProgram = "browseros";
  };
}
