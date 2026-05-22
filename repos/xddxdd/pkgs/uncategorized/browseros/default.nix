{
  appimageTools,
  lib,
  sources,
}:

let
  contents = appimageTools.extractType2 {
    inherit (sources.browseros) pname src version;
  };
in
appimageTools.wrapType2 rec {
  inherit (sources.browseros) pname src version;

  extraInstallCommands = ''
    install -Dm644 ${contents}/browseros.desktop $out/share/applications/browseros.desktop
    substituteInPlace $out/share/applications/browseros.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=browseros'
    install -Dm644 ${contents}/browseros.png $out/share/pixmaps/browseros.png
  '';

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
