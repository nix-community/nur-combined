{
  lib,
  stdenv,
  autoPatchelfHook,
  dpkg,
  fetchurl,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libsecret,
  libxkbcommon,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  libXtst,
  libxshmfence,
  nspr,
  nss,
  pango,
  systemd,
  udev,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jlcone";
  version = "1.0.67";

  src = fetchurl {
    url = "https://rs.jlcpcb.com/static/APP/app_version/jlcone-${finalAttrs.version}.deb";
    hash = "sha256-2ab9InOz9UCxUwxvGxiN6xrN1YPV7hdSJAVd/P4AVIM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libsecret
    libxkbcommon
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libXtst
    libxshmfence
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    udev
    zlib
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/opt/jlcone" "$out/share"

    cp -a opt/JLCONE/. "$out/opt/jlcone/"

    if [ -d usr/share ]; then
      cp -a usr/share/. "$out/share/"
    fi

    # Fix the desktop file to point to the wrapper binary
    if [ -f "$out/share/applications/jlcone.desktop" ]; then
      substituteInPlace "$out/share/applications/jlcone.desktop" \
        --replace-warn "/opt/JLCONE/jlcone" "jlcone"
    fi

    # chrome-sandbox requires setuid in a real install; under Nix we pass --no-sandbox
    makeWrapper "$out/opt/jlcone/jlcone" "$out/bin/jlcone" \
      --chdir "$out/opt/jlcone" \
      --prefix LD_LIBRARY_PATH : "$out/opt/jlcone" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      --add-flags "--no-sandbox"

    runHook postInstall
  '';

  dontStrip = true;

  meta = {
    description = "JLCPCB desktop client (JLCONE)";
    longDescription = ''
      JLCONE is the official desktop client for JLCPCB, the PCB prototyping
      and assembly service. Built on Electron.
    '';
    homepage = "https://jlcpcb.com/download";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "jlcone";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
