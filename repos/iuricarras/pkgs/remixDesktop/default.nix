{
  lib,
  pkgs,
  appimageTools,
  fetchurl,
}: let
  version = "1.1.6";
  pname = "remix-desktop";

  src = fetchurl {
    url = "https://github.com/remix-project-org/remix-desktop/releases/download/v${version}/Remix-Desktop-${version}.AppImage";
    hash = "sha256:cadb458aff47648e97b4fbed7403f0b4ec55b9013ad9317d2e7c963362b6f487";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname src version;

    postExtract = ''
      substituteInPlace $out/Remix-Desktop.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=remix-desktop --no-sandbox %U'
    '';
  };
in
  appimageTools.wrapType2 rec {
    inherit pname version src;

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      ln -s ${appimageContents}/Remix-Desktop.desktop $out/share/applications/

      mkdir -p $out/share/icons/hicolor/48x48/apps
      ln -s ${appimageContents}/Remix-Desktop.png $out/share/icons/hicolor/48x48/apps/
    '';

    meta = {
      description = "Remix Desktop is a powerful, open-source IDE for Ethereum development.";
      homepage = "https://remix.ethereum.org/";
      downloadPage = "https://github.com/remix-project-org/remix-desktop/releases";
      mainProgram = "Remix-Desktop-1.1.6";
      license = lib.licenses.apsl20;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = ["x86_64-linux"];
    };
  }
