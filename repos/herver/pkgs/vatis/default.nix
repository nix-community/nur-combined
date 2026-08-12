{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  makeWrapper,
  pkgs,
}:

let
  version = "4.1.0-beta.19";
  pname = "vatis";

  src = fetchurl {
    # No versioned URL available; always serves latest
    url = "https://hub.vatis.app/download/linux";
    hash = "sha256-Wn7vQepoI1wzP5oyAfUDMzVV28vGyR0DvKp6AaCuqB0=";
    name = "vATIS-${version}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = appimageContents;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = with pkgs; [
    curl
    zlib
    fontconfig
    stdenv.cc.cc.lib # libstdc++
  ];

  runtimeDependencies = [
    (lib.getLib pkgs.icu)
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share/applications $out/share/icons/hicolor/256x256/apps

    cp -r usr/bin/* $out/lib/
    cp org.vatsim.vatis.png $out/share/icons/hicolor/256x256/apps/org.vatsim.vatis.png

    # Desktop file
    cp org.vatsim.vatis.desktop $out/share/applications/vatis.desktop
    substituteInPlace $out/share/applications/vatis.desktop \
      --replace-fail 'Exec=vATIS' 'Exec=vatis'

    makeWrapper $out/lib/vATIS $out/bin/vatis \
      --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
      --prefix LD_LIBRARY_PATH : "$out/lib:${lib.makeLibraryPath [
        pkgs.libGL
        pkgs.vulkan-loader
        pkgs.xorg.libX11
        pkgs.xorg.libXcursor
        pkgs.xorg.libXi
        pkgs.xorg.libXrandr
        pkgs.xorg.libICE
        pkgs.xorg.libSM
        pkgs.alsa-lib
        pkgs.libpulseaudio
      ]}"

    runHook postInstall
  '';

  meta = {
    description = "A next generation ATIS client for the VATSIM network";
    homepage = "https://github.com/vatis-project/vatis";
    downloadPage = "https://hub.vatis.app/download/linux";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "vatis";
  };
}
