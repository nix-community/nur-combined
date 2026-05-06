{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  pkgs,
}:

let
  version = "1.3.3";
  pname = "trackaudio";

  src = fetchurl {
    url = "https://github.com/pierr3/TrackAudio/releases/download/${version}/${pname}_${version}_amd64.deb";
    hash = "sha256-hCeXIIj3D1jXvRd4U+gvHKrrbNPnlHm4QENDfFf/HiQ=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = with pkgs; [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libpulseaudio
    libxkbcommon
    mesa
    nspr
    nss
    pango
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXt
    xorg.libXtst
    xorg.libxcb
    systemdMinimal # libudev
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    dpkg-deb -x $src .

    mkdir -p $out/bin $out/share
    cp -r opt/TrackAudio $out/lib
    cp -r usr/share/* $out/share/

    # Fix desktop file to point to wrapped binary
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail '/opt/TrackAudio/trackaudio' '${pname}'

    makeWrapper $out/lib/trackaudio $out/bin/trackaudio \
      --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        pkgs.libGL
        pkgs.vulkan-loader
        # miniaudio (via afv-native) dlopen()s these at runtime
        pkgs.alsa-lib
        pkgs.libpulseaudio
      ]}"

    runHook postInstall
  '';

  meta = {
    description = "A next generation Audio-For-VATSIM ATC Client";
    homepage = "https://github.com/pierr3/TrackAudio";
    downloadPage = "https://github.com/pierr3/TrackAudio/releases";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "trackaudio";
  };
}
