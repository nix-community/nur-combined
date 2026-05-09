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
  version = "1.0.9";
  pname = "proton-meet";

  src = fetchurl {
    url = "https://proton.me/download/meet/linux/${version}/ProtonMeet-desktop.deb";
    hash = "sha256-eDRSHOMzJpLwpUfud55hBbVjlAPJn2jopqaDtRemigw=";
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

    # Extract without preserving setuid bit on chrome-sandbox
    dpkg-deb --fsys-tarfile $src | tar x --no-same-permissions

    mkdir -p $out/bin $out/share
    cp -r usr/lib/proton-meet $out/lib
    cp -r usr/share/* $out/share/

    makeWrapper "$out/lib/Proton Meet Beta" $out/bin/proton-meet \
      --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        pkgs.libGL
        pkgs.vulkan-loader
        pkgs.alsa-lib
        pkgs.libpulseaudio
      ]}"

    runHook postInstall
  '';

  meta = {
    description = "Proton Meet desktop client for secure video conferencing";
    homepage = "https://proton.me/meet";
    downloadPage = "https://proton.me/meet/download";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "proton-meet";
  };
}
