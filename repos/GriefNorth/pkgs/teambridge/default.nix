{
  lib,
  appimageTools,
  fetchurl,
}:

let
  version = "6.1.7";
  pname = "teambridge";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://teambridge.pro/teambridge-builds/release/desktop/${version}/teambridge-desktop-${version}-linux-x86_64.AppImage";
    hash = "sha256-cftUPNCX6SrIWv5OKkWqLSYXZ69Ff42mc97naQ7rvfs=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/teambridge-desktop.desktop $out/share/applications/teambridge-desktop.desktop
    substituteInPlace $out/share/applications/teambridge-desktop.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
    install -Dm644 ${appimageContents}/teambridge-desktop.png $out/share/icons/hicolor/256x256/apps/teambridge-desktop.png
  '';

  meta = {
    description = "TeamBridge desktop client for corporate communication";
    homepage = "https://teambridge.pro";
    downloadPage = "https://teambridge.pro/teambridge-builds/release/desktop/${version}/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "teambridge";
  };
}
