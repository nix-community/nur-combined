{
  appimageTools,
  fetchurl,
  lib,
}:

let
  version = "0.47.18";

  src = fetchurl {
    url = "https://github.com/browseros-ai/BrowserOS/releases/download/v${version}/BrowserOS_v${version}_x64.AppImage";
    hash = "sha256-j17ERzRxTx/0OaKtSjp02DXi132Rfz9qse5uI7auu7s=";
  };

  contents = appimageTools.extractType2 {
    pname = "browseros";
    inherit version src;
  };
in
appimageTools.wrapType2 {
  pname = "browseros";
  inherit version src;

  extraInstallCommands = ''
    install -Dm644 ${contents}/browseros.desktop $out/share/applications/browseros.desktop
    substituteInPlace $out/share/applications/browseros.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=browseros'
    install -Dm644 ${contents}/browseros.png $out/share/pixmaps/browseros.png
  '';

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    changelog = "https://github.com/browseros-ai/BrowserOS/releases/tag/v${version}";
    homepage = "https://www.browseros.com";
    description = "Open source agentic browser";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "browseros";
  };
}
