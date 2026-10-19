{
  lib,
  pkgs,
  fetchurl,
  appimageTools,
}:

let
  pname = "appimagetool";
  description = "A low-level tool to generate an AppImage from an existing AppDir";
  version = "1.9.1";

  src = fetchurl {
    url = "https://github.com/AppImage/appimagetool/releases/download/${version}/appimagetool-x86_64.AppImage";
    hash = "sha256-7UzoTw2cr/ZvULzKb/bzWq5UzoE1QIs/ozq/w8s4TrA=";
  };

  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [ ];

  extraInstallCommands = ''
    install -Dm444 "${contents}/${pname}.desktop" "$out/share/applications/${pname}.desktop"
    install -Dm444 "${contents}/${pname}.png" "$out/share/icons/hicolor/256x256/apps/${pname}.png"
    substituteInPlace "$out/share/applications/${pname}.desktop" --replace "Exec=AppRun" "Exec=${pname}-linux-x86_64"
  '';

  meta = {
    description = "Generate AppImages from existing AppDirs";
    homepage = "https://github.com/AppImage/appimagetool";
    downloadPage = "https://github.com/AppImage/appimagetool/releases";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "appimagetool";
  };
}
