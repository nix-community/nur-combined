{ buildFHSUserEnv, stdenv, fetchurl, writeScriptBin, callPackage, makeDesktopItem }:

let 
  nixGL = import (fetchTarball {
    url = "https://github.com/guibou/nixGL/archive/04a6b0833fbb46a0f7e83ab477599c5f3eb60564.tar.gz";
    sha256 = "0z1zafkb02sxng91nsx0gclc7n7sv3d5f23gp80s3mc07p22m1k5";
  }) {};
  firestorm = stdenv.mkDerivation rec {
    pname = "firestorm";
    version = "6.0.2.56680";
    src = fetchurl {
      sha256 = "1n9psqaxx1w3fskryqcl313fhqx13wb72z5xricxqkx1q2xl8xv6";
      url = "https://downloads.firestormviewer.org/linux/Phoenix_FirestormOS-Releasex64_x86_64_${version}.tar.xz";
    };
    installPhase = ''
      mkdir -p $out/opt
      cp -r . $out/opt
      ls -lah $out/opt
    '';
    dontStrip = true;
  };
  firestorm-launcher = writeScriptBin "firestorm" ''
    cd "${firestorm}/opt"
    ${nixGL.nixGLIntel}/bin/nixGLIntel ./firestorm $*
    exit $?
  '';
  firestorm-desktop = makeDesktopItem {
    name = "firestorm";
    desktopName = "Firestorm Viewer";
    comment = "Client for accessing 3D virtual words";
    exec = "${fhs-firestorm}/bin/fhs-firestorm";
    icon = "${firestorm}/opt/firestorm_icon.png";
    categories = "Application;Internet;Network";
    startupNotify = "true";
    extraEntries = "StartupWMClass=do-not-directly-run-firestorm-bin";
  };
  fhs-firestorm = buildFHSUserEnv {
    name = "fhs-firestorm";
    targetPkgs = pkgs: (with pkgs; [
      alsaLib
      SDL apr aprutil atk cairo curl db dbus_glib freealut freetype
      gtk2 hunspell jsoncpp libGL libjpeg libogg libpng libvorbis nghttp2 openal
      opencollada openjpeg pangox_compat pcre uriparser zlib
      glib.out libGLU xorg.libX11 fontconfig xorg.libXrandr
    ]);
    runScript = "${firestorm-launcher}/bin/firestorm";
  };
in stdenv.mkDerivation {
  inherit (firestorm) pname version;
  buildCommand = ''
    mkdir -p $out/bin $out/share/applications
    ln -s ${firestorm-desktop}/share/applications/* $out/share/applications
    ln -s ${fhs-firestorm}/bin/fhs-firestorm $out/bin/firestorm
  '';
}
