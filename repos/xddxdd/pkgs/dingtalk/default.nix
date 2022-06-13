{ stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, lib
, callPackage
  # DingTalk dependencies
, alsa-lib
, at-spi2-atk
, at-spi2-core
, cairo
, cups
, dbus
, e2fsprogs
, gdk-pixbuf
, glib
, gnutls
, graphite2
, gtk2
, krb5
, libdrm
, libgcrypt
, libGLU
, libpulseaudio
, libthai
, libxkbcommon
, mesa_drivers
, nspr
, nss
, rtmpdump
, udev
, util-linux
, xorg
, ...
} @ args:

################################################################################
# Mostly based on dingtalk-bin package from AUR:
# https://aur.archlinux.org/packages/dingtalk-bin
################################################################################

let
  version = "1.4.0.20425";

  openldap = callPackage ./openldap-2_4.nix { };

  libraries = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    e2fsprogs
    gdk-pixbuf
    glib
    gnutls
    graphite2
    gtk2
    krb5
    libdrm
    libgcrypt
    libGLU
    libpulseaudio
    libthai
    libxkbcommon
    mesa_drivers
    nspr
    nss
    openldap
    rtmpdump
    udev
    util-linux
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXmu
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXt
    xorg.libXtst
  ];
in
stdenv.mkDerivation rec {
  pname = "dingtalk";
  inherit version;
  src = fetchurl {
    url = "https://dtapp-pub.dingtalk.com/dingtalk-desktop/xc_dingtalk_update/linux_deb/Release/com.alibabainc.dingtalk_${version}_amd64.deb";
    sha256 = "sha256-UKkFuuFK/Ae+XIWbPYYsqwS/FOJfOqm9e1i18JB8UfA=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = libraries;

  unpackPhase = ''
    ar x ${src}
    tar xf data.tar.xz

    mv opt/apps/com.alibabainc.dingtalk/files/version version
    mv opt/apps/com.alibabainc.dingtalk/files/*-Release.* release

    # Cleanup
    rm -rf release/Resources/{i18n/tool/*.exe,qss/mac}
    rm -f release/{*.a,*.la,*.prl}
    rm -f release/dingtalk_updater
    rm -f release/libgtk-x11-2.0.so.*
    rm -f release/libm.so.*
  '';

  installPhase = ''
    mkdir -p $out
    mv version $out/

    # Move libraries
    # DingTalk relies on (some of) the exact libraries it ships with
    mv release $out/lib

    # Entrypoint
    mkdir -p $out/bin
    makeWrapper $out/lib/com.alibabainc.dingtalk $out/bin/dingtalk \
      --argv0 "com.alibabainc.dingtalk" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}"

    # App Menu
    mkdir -p $out/share/applications $out/share/pixmaps
    ln -s ${./dingtalk.desktop} $out/share/applications/dingtalk.desktop
    ln -s ${./dingtalk.png} $out/share/pixmaps/dingtalk.png
  '';

  meta = with lib; {
    description = "钉钉";
    homepage = "https://www.dingtalk.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}
