{
  lib,
  fetchurl,
  appimageTools,
  makeWrapper,
}:
let
  pname = "beeper";
  version = "4.0.693";
  src = fetchurl {
    url = "https://beeper-desktop.download.beeper.com/builds/Beeper-${version}.AppImage";
    hash = "sha256-+m4pmDYnn4fWAp8Ve7hjNaFClPU8tLIAVGQSJNlo/p0=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;

    postExtract = ''
      # disable creating a desktop file and icon in the home folder during runtime
      linuxConfigFilename=$out/resources/app/build/main/linux-*.mjs
      echo "export function registerLinuxConfig() {}" > $linuxConfigFilename

      # disable auto update
      sed -i 's/[^=]*\.auto_update_disabled/true/' $out/resources/app/build/main/main-entry-*.mjs

      # prevent updates
      sed -i -E 's/executeDownload\([^)]+\)\{/executeDownload(){return;/g' $out/resources/app/build/main/main-entry-*.mjs
    '';
  };
in

appimageTools.wrapAppImage {
  inherit pname version;

  src = appimageContents;

  extraPkgs = pkgs: [ pkgs.libsecret ];

  extraInstallCommands = ''
    mkdir -p $out/share/icons/hicolor
    cp -a ${appimageContents}/usr/share/icons/hicolor/512x512 $out/share/icons/hicolor/512x512
    install -Dm 644 ${appimageContents}/beepertexts.desktop -t $out/share/applications/

    substituteInPlace $out/share/applications/beepertexts.desktop --replace-fail "AppRun" "beeper"

    . ${makeWrapper}/nix-support/setup-hook
    wrapProgram $out/bin/beeper \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} --no-update" \
      --set APPIMAGE beeper
  '';

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
