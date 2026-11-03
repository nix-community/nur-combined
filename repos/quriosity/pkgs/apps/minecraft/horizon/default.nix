{ lib, appimageTools, fetchurl, makeDesktopItem, writeScript, nix-update-script }:

let
  pname = "horizon-launcher";
  version = "0.2.37";

  src = fetchurl {
    url = "https://github.com/horizon-rust/horizon/releases/download/launcher%40${version}/horizon-launcher-linux-x86_64.AppImage";
    hash = "sha256-acqmENt1zLYR/qdBtQNY5ZgivY/8duCY/FqKXbaybtg=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname}";
    icon = pname;
    desktopName = "Horizon";
    comment = "Minecraft: Java Edition 26.3 rewritten from scratch in Rust, checked against vanilla with 281 differential harnesses";
    categories = [ "Game" "ActionGame" ];
    keywords = [ "minecraft" "rust" ];
    startupNotify = true;
    startupWMClass = "horizon-launcher";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
      # Build toolchain required by the launcher's "native build" feature
      # (compiling native mods into the game; see horizon docs/native-mods.md).
      gcc
      pkg-config
      alsa-lib
      alsa-lib.dev
      systemd
      systemd.dev
      gnumake
      git
      rsync
      curl
      cacert
    ];

  extraInstallCommands = ''
    install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop

    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/horizon.png \
      $out/usr/share/icons/hicolor/512x512/apps/horizon.png
  '';

  passthru.updateScript = writeScript "update-horizon" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq common-updater-scripts
      repo="https://api.github.com/repos/horizon-rust/horizon/releases"
      version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output)"
      update-source-version horizon "''${version#v}"
    '';

  meta = with lib; {
    description = "Minecraft: Java Edition 26.3 rewritten from scratch in Rust, checked against vanilla with 281 differential harnesses.";
    homepage = "https://github.com/horizon-rust/horizon";
    license = licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "horizon-launcher";
  };
}
