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
  pname = "binance";
  # Binance tidak menyediakan URL download per versi secara terpisah untuk Linux,
  # melainkan selalu menimpa berkas binance-amd64-linux.deb di URL statis berikut.
  # Jika terjadi error hash mismatch, jalankan `nix-prefetch-url` pada URL di bawah,
  # lalu perbarui versi (cek via `dpkg-deb -I` di environment ber-dpkg) dan sha256.
  version = "2.4.1";

  src = fetchurl {
    url = "https://download.binance.com/electron-desktop/linux/production/binance-amd64-linux.deb";
    sha256 = "sha256-7K5ZGUr/WpiUAXOChgEjCqQEBjgxQ609Xut87B0KS5U=";
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

  installPhase = ''
    mkdir -p $out/bin $out/opt $out/share

    cp -r opt/Binance $out/opt/
    cp -r usr/share/* $out/share/

    makeWrapper $out/opt/Binance/binance $out/bin/binance \
      --add-flags "--disable-gpu"
      
    substituteInPlace $out/share/applications/binance.desktop \
      --replace "/opt/Binance/binance" "$out/bin/binance"
  '';

  meta = with lib; {
    description = "Binance Desktop App";
    homepage = "https://www.binance.com";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "binance";
    platforms = platforms.linux;
  };
}
