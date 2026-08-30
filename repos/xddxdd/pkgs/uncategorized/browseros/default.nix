{
  appimageTools,
  fetchurl,
  lib,
  nix-update-script,
}:

let
  contents = appimageTools.extractType2 {
    pname = "browseros";
    src = fetchurl {
      url = "https://github.com/browseros-ai/BrowserOS/releases/download/v0.47.18/BrowserOS_v0.47.18_x64.AppImage";
      hash = "sha256-j17ERzRxTx/0OaKtSjp02DXi132Rfz9qse5uI7auu7s=";
    };
    version = "0.47.18";
  };
in
appimageTools.wrapType2 rec {
  pname = "browseros";
  src = fetchurl {
    url = "https://github.com/browseros-ai/BrowserOS/releases/download/v0.47.18/BrowserOS_v0.47.18_x64.AppImage";
    hash = "sha256-j17ERzRxTx/0OaKtSjp02DXi132Rfz9qse5uI7auu7s=";
  };
  version = "agent-server/v0.0.147";
  extraInstallCommands = ''
    install -Dm644 ${contents}/browseros.desktop $out/share/applications/browseros.desktop
    substituteInPlace $out/share/applications/browseros.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=browseros'
    install -Dm644 ${contents}/browseros.png $out/share/pixmaps/browseros.png
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/browseros-ai/BrowserOS/releases/tag/${version}";
    homepage = "https://www.browseros.com";
    description = "Open source agentic browser";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "browseros";
  };
}
