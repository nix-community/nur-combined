{ lib, appimageTools, fetchurl, makeDesktopItem, writeScript, nix-update-script }:

let
  pname = "cinnabar";
  version = "0.2.1";

  src = fetchurl {
    url = "https://github.com/cinnabar-mc/cinnabar/releases/download/v${version}/Cinnabar-x86_64.AppImage";
    hash = "sha256-CgQhAujxHcZIup0lF1fjvQbBQ9vvCFQjKWt2jXqx0TY=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname}";
    icon = pname;
    desktopName = "Cinnabar";
    comment = "Minecraft: Bedrock Edition, rebuilt from scratch in Rust. A fast, vanilla-accurate desktop client";
    categories = [ "Game" "ActionGame" ];
    keywords = [ "minecraft" "rust" "mcbe" ];
    startupNotify = true;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  

  extraInstallCommands = ''
    install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop

    install -m 444 -D ${appimageContents}/cinnabar.png \
      $out/usr/share/icons/hicolor/512x512/apps/cinnabar.png
  '';

  passthru.updateScript = writeScript "update-cinnabar" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq common-updater-scripts
      repo="https://api.github.com/repos/cinnabar-mc/cinnabar/releases"
      version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output)"
      update-source-version cinnabar "''${version#v}"
    '';

  meta = with lib; {
    description = "Minecraft: Bedrock Edition, rebuilt from scratch in Rust";
    homepage = "https://github.com/cinnabar-mc/cinnabar";
    license = licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "cinnabar";
  };
}
