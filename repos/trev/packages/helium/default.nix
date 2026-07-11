{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
}:
let
  pname = "helium";
  version = "0.14.5.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-JM4Tm4Le9Xcfq3fFMEu/DIK6817FEgBQ2rSwY093F04=";
  };

  contents = appimageTools.extract { inherit pname version src; };
in

appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${contents}/helium.desktop $out/share/applications/helium.desktop
    install -m 444 -D ${contents}/usr/share/icons/hicolor/256x256/apps/helium.png \
      $out/share/icons/hicolor/256x256/apps/helium.png
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      pname
    ];
  };

  meta = {
    mainProgram = "helium";
    description = "Helium Browser for Linux";
    homepage = "https://github.com/imputnet/helium-linux";
    changelog = "https://github.com/imputnet/helium-linux/releases/tag/V${version}";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
