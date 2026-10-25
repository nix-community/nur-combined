{ lib, appimageTools, fetchurl, makeDesktopItem, nix-update-script }:

let
  pname = "paintdotjs";
  version = "2.4.5";

  src = fetchurl {
    url = "https://github.com/LabyStudio/paintdotjs/releases/download/v${version}/paintdotjs-${version}-linux-x86_64.AppImage";
    hash = "sha256-4zEV6pnRJxn4EMma8drRfyODdtgGmukabRJ/i4w+qbA=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} --no-sandbox %U";
    icon = pname;
    desktopName = "Paint.js";
    comment = "An open source general-purpose raster graphics editor with support for multiple documents, layers, and common image formats.";
    categories = [ "Graphics" ];
    startupNotify = true;
    startupWMClass = "paintdotjs";
    mimeTypes = [ "application/x-paintdotnet" "image/png" "image/jpeg" "image/webp" "image/gif" "image/bmp" "image/tiff" "image/jxl" "image/avif" "image/heic" "image/heif" "image/vnd-ms.dds" "image/x-tga" "image/vnd.ms-photo" ];
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop

    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/1024x1024/apps/paintdotjs.png \
      $out/share/icons/hicolor/1024x1024/apps/${pname}.png
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "cross-platform raster graphics editor written in JavaScript";
    homepage = "https://github.com/LabyStudio/paintdotjs";
    license = licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "paintdotjs";
  };
}
