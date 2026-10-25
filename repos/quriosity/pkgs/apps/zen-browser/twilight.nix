{ lib, appimageTools, fetchurl, makeDesktopItem, nix-update-script }:

let
  pname = "zen-browser-twilight";
  version = "1.23.4b";

  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/twilight-1/zen-x86_64.AppImage";
    hash = "sha256-Vs7PCjW7AffT1AgnLHe9NmdG/KI24jl3MzQkniCL+Zw=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} %u";
    icon = pname;
    desktopName = "Zen Browser Twilight";
    genericName = "Web Browser";
    categories = [ "Network" "WebBrowser" ];
    startupWMClass = "zen";
    mimeTypes = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "application/vnd.mozilla.xul+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
     install -m 444 -D ${desktopItem}/share/applications/*.desktop $out/share/applications/${pname}.desktop
     install -m 444 -D ${appimageContents}/zen.png $out/share/icons/hicolor/512x512/apps/${pname}.png

     substituteInPlace $out/share/applications/${pname}.desktop \
       --replace-fail "Exec=${pname} %u" "Exec=$out/bin/${pname} %u"
   '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "a twilight build of Zen Browser";
    homepage = "https://zen-browser.app/";
    license = licenses.mpl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "zen-browser-twilight";
  };
}
