{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "virtualparadise";
  version = "0.4.9";

  src = fetchurl {
    url = "https://static.virtualparadise.org/downloads/Virtual_Paradise-${version}-1-x86_64.AppImage";
    hash = "sha256-AdfyqjHcACbZi+V4dFgkdWISrrxtN8CfNzkVgd3QXgQ=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/virtualparadise.desktop $out/share/applications/virtualparadise.desktop
    install -m 444 -D ${appimageContents}/virtualparadise.png $out/share/icons/hicolor/128x128/apps/virtualparadise.png
  '';

  meta = with lib; {
    description = "Online virtual universe consisting of several 3D worlds";
    homepage = "https://www.virtualparadise.org";
    license = licenses.unfree;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "virtualparadise";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
