{ stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, writeText
, lib
  # QQ Music dependencies
, alsa-lib
, at-spi2-atk
, at-spi2-core
, cairo
, cups
, dbus
, expat
, gdk-pixbuf
, glib
, gtk3
, libpulseaudio
, mesa_drivers
, nspr
, nss
, pango
, pciutils
, udev
, xorg
, ...
} @ args:

################################################################################
# Mostly based on qqmusic-bin package from AUR:
# https://aur.archlinux.org/packages/qqmusic-bin
################################################################################

let
  libraries = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libpulseaudio
    mesa_drivers
    nspr
    nss
    pango
    pciutils
    udev
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
  ];

  desktopFile = writeText "qqmusic.desktop" ''
    [Desktop Entry]
    Name=qqmusic
    Exec=qqmusic %U
    Terminal=false
    Type=Application
    Icon=qqmusic
    StartupWMClass=qqmusic
    Comment=Tencent QQMusic
    Categories=AudioVideo;
  '';
in
stdenv.mkDerivation rec {
  pname = "qqmusic";
  version = "1.1.3";
  src = fetchurl {
    url = "https://dldir1.qq.com/music/clntupate/linux/deb/qqmusic_${version}_amd64.deb";
    sha256 = "sha256-Rxhq9cTLmeCPjMxyWQJ/+xaNK1tznymfLYU1dbIOL+c=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = libraries;

  unpackPhase = ''
    ar x ${src}
    tar xf data.tar.xz
  '';

  installPhase = ''
    mkdir -p $out
    cp -r opt/qqmusic $out/opt
    cp -r usr/* $out/
    ln -sf ${desktopFile} $out/share/applications/qqmusic.desktop

    mkdir -p $out/bin
    makeWrapper $out/opt/qqmusic $out/bin/qqmusic \
      --argv0 "qqmusic" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}"

    # Hex patch
    # 1. Fix orphaned processes
    # 2. Fix search
    local _subst="
        s|\xA4\x8B\x7A\xB9\x8D\xCF\x54\xAE|\xA4\x8B\x7A\xB9\x85\xEF\x54\xAE|
        s|\xB3\x1D\xF5\xCB\x24\xBC|\xA3\x63\xBB\xC9\x3F\xBC|
    "
    sed "$_subst" -i "$out/opt/resources/app.asar"
  '';

  meta = with lib; {
    description = "Tencent QQ Music (Untested)";
    homepage = "https://y.qq.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}
