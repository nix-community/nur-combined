{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  makeWrapper,
  autoPatchelfHook,
  alsa-lib,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  udev,
  libglvnd,
  libsecret,
  libx11,
  libxscrnsaver,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
  libxcb,
  libxshmfence,
  procps,
}:

stdenv.mkDerivation rec {
  pname = "streambert";
  version = "2.6.0";

  src = fetchurl {
    url = "https://github.com/truelockmc/streambert/releases/download/${version}/streambert_${version}_amd64.deb";
    sha256 = "sha256-QfmrSVrZdmyHnh7lTqDTWa4G7YXtDSONUFeZnw4xomI=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    udev
    libglvnd
    libsecret
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
    libxshmfence
    procps
  ];

  unpackPhase = ''
    dpkg -x $src .
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/opt $out/share

    cp -r opt/Streambert $out/opt/
    cp -r usr/share/* $out/share/

    makeWrapper $out/opt/Streambert/streambert $out/bin/streambert \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    substituteInPlace $out/share/applications/streambert.desktop \
      --replace "/opt/Streambert/streambert" "$out/bin/streambert"
  '';

  meta = with lib; {
    description = "Streambert - A cross-platform Electron Desktop app for streaming";
    homepage = "https://github.com/truelockmc/streambert";
    license = licenses.gpl3;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "streambert";
    platforms = [ "x86_64-linux" ];
  };
}
