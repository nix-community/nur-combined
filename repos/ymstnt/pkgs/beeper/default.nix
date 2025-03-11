{
  lib,
  fetchurl,
  appimageTools,
  makeWrapper,
  writeShellApplication,
  curl,
  yq,
  common-updater-scripts,
}:
let
  pname = "beeper";
  version = "4.0.522";
  src = fetchurl {
    url = "https://beeper-desktop.download.beeper.com/builds/Beeper-${version}.AppImage";
    hash = "sha256-qXVZEIk95p5sWdg6stQWUQn/w4+JQmDR6HySlGC5yAk=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;

    postExtract = ''
      # disable creating a desktop file and icon in the home folder during runtime
      linuxConfigFilename=$out/resources/app/build/main/linux-*.mjs
      echo "export function registerLinuxConfig() {}" > $linuxConfigFilename
    '';
  };
in

appimageTools.wrapAppImage {
  inherit pname version;

  src = appimageContents;

  extraPkgs = pkgs: [ pkgs.libsecret ];

  extraInstallCommands = ''
    mkdir -p $out/share/icons/hicolor
    cp -a ${appimageContents}/usr/share/icons/hicolor/0x0 $out/share/icons/hicolor/512x512
    install -Dm 644 ${appimageContents}/beepertexts.desktop -t $out/share/applications/

    substituteInPlace $out/share/applications/beepertexts.desktop --replace-fail "AppRun" "beeper"

    . ${makeWrapper}/nix-support/setup-hook
    wrapProgram $out/bin/beeper \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} --no-update" \
      --set APPIMAGE beeper
  '';

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-beeper";
      runtimeInputs = [
        curl
        yq
        common-updater-scripts
      ];
      text = ''
        set -o errexit
        latestLinux="$(curl -s https://download.todesktop.com/2003241lzgn20jd/latest-linux.yml)"
        version="$(echo "$latestLinux" | yq -r .version)"
        update-source-version beeper "$version" "" "https://download.beeper.com/versions/$version/linux/appImage/x64" --source-key=src.src
      '';
    });
  };

  meta ={
    description = "Universal chat app";
    longDescription = ''
      Beeper is a universal chat app. With Beeper, you can send
      and receive messages to friends, family and colleagues on
      many different chat networks.
    '';
    homepage = "https://beeper.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "beeper";
    platforms = [ "x86_64-linux" ];
  };
}
