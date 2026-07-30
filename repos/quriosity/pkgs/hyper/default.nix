{ lib, appimageTools, fetchurl, makeDesktopItem, nix-update-script }:

let
  pname = "Hyper";
  version = "4.0.0-q";

  src = fetchurl {
    url = "https://github.com/quine-global/hyper/releases/download/v${version}-canary.14/Hyper-${version}-canary.13-x86_64.AppImage";
    hash = "sha256-0iV+0fC50J7lEKtKjCTQWqrh5HVmv/dhjqKULAci7V8=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} --no-sandbox %U";
    icon = pname;
    desktopName = "Hyper";
    comment = "A terminal built on web technologies";
    categories = [ "TerminalEmulator" ];
    startupWMClass = "Hyper";
    mimeTypes = [
      "x-scheme-handler/ssh"
    ];
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop

    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/256x256/apps/hyper.png \
      $out/share/icons/hicolor/256x256/apps/${pname}.png
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "a terminal built on web technologies";
    homepage = "https://github.com/quine-global/hyper";
    license = licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "Hyper";
  };
}
