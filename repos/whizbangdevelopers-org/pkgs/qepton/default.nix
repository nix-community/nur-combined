{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "qepton";
  version = "1.0.22";

  src = fetchurl {
    url = "https://github.com/whizbangdevelopers-org/Qepton/releases/download/v${version}/Qepton-${version}.AppImage";
    hash = "sha256-0MG44A/RYtaqnCwCm8Y3+lkOszBECdlUXwk8rcAJ0Eg=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/qepton.desktop $out/share/applications/qepton.desktop
    install -m 444 -D ${appimageContents}/qepton.png $out/share/icons/hicolor/512x512/apps/qepton.png
    substituteInPlace $out/share/applications/qepton.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox' 'Exec=qepton'
  '';

  meta = {
    description = "AI Prompt and Code Snippet Manager powered by GitHub Gist";
    homepage = "https://github.com/whizbangdevelopers-org/Qepton";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "qepton";
  };
}
