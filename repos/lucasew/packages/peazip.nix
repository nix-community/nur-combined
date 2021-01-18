{pkgs ? import <nixpkgs> {}}:
with pkgs;
let
  src = builtins.fetchTarball {
    url = "https://github.com/peazip/PeaZip/releases/download/7.7.0/peazip_portable-7.7.0.LINUX.x86_64.GTK2.tar.gz";
    sha256 = "sha256:0pxdbkpy2q0a12nsqvpxjiss9bfxzsyz1srvdpln1r7v78sdvwv6";
  };
  fhs = buildFHSUserEnv {
    name = "peazip";
    targetPkgs = pkgs: with pkgs; [
      glib
      gtk2-x11
      xorg.libX11
      gdk-pixbuf
      pango
      cairo
      atk
    ];
    runScript = "${src}/peazip $*";
  };
  desktop = makeDesktopItem {
    desktopName = "PeaZip";
    name = "peazip";
    genericName = "Compressed files";
    type = "Application";
    terminal = false;
    categories="GTK;Qt;Utility;System;Archiving;";
    exec = "${fhs}/bin/peazip %F";
    icon = "${src}/FreeDesktop_integration/peazip.png";
    mimeType="application/x-gzip;application/x-lha;application/x-tar;application/x-tgz;application/x-tbz;application/x-tbz2;application/x-zip;application/zip;application/x-bzip;application/x-rar;application/x-tarz;application/x-archive;application/x-bzip2;application/x-jar;application/x-deb;application/x-ace;application/x-7z;application/x-arc;application/x-arj;application/x-compress;application/x-cpio;";
  };
in stdenv.mkDerivation {
  name = "PeaZip";
  inherit src;
  installPhase = ''
    mkdir -p $out
    cp -r ${desktop}/* $out
    cp -r ${fhs}/* $out
  '';
}
