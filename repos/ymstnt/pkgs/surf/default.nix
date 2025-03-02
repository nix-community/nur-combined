{
  lib,
  requireFile,
  appimageTools,
}:

let
  pname = "surf";
  version = source.version;

  source = lib.importJSON ./source.json;

  # As per Deta Surf's Terms of Service (https://deta.surf/terms), the binary is non-distributable.
  # Thus, the user needs to sign up for an invite for the closed alpha on https://deta.surf/ with their email.
  # After receiving an invite, the user should download the .AppImage file from the download link provided in the email,
  # then it should be added into the nix store
  src = requireFile {
    name = "Surf-${version}.x86_64.AppImage";
    hash = source.hash;
    url = "https://deta.surf/";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/desktop.desktop $out/share/applications/Surf.desktop
    install -m 444 -D ${appimageContents}/desktop.png $out/share/icons/hicolor/512x512/apps/Surf.png
    substituteInPlace $out/share/applications/Surf.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=surf' \
      --replace-fail 'Icon=desktop' 'Icon=Surf'
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Browser, file manager, and AI assistant — all in one.";
    homepage = "https://deta.surf/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "surf";
    platforms = [ "x86_64-linux" ];
  };
}
