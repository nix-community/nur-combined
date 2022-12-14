{ stdenv, pkgs, lib, fetchurl }:

stdenv.mkDerivation rec {
  name = "microsoft-todo-electron";
  version = "1.3.0";

  phases = [ "unpackPhase" "installPhase" ];

  rpath = with pkgs; lib.makeLibraryPath [
    atk
    nss
    nspr
    zlib
    glib
    gtk3
    mesa
    cups
    dbus
    expat
    cairo
    pango
    libpng
    libdrm
    systemd
    alsa-lib
    freetype
    gdk-pixbuf
    fontconfig
    xorg.libXi
    xorg.libX11
    xorg.libxcb
    xorg.libXext
    stdenv.cc.cc
    at-spi2-core
    libxkbcommon
    xorg.libXrandr
    xorg.libXfixes
    xorg.libXcursor
    xorg.libXrender
    xorg.libXdamage
    xorg.libXcomposite
  ];

  src = fetchurl {
    url = "https://github.com/Thaumy/Microsoft-ToDo-Electron/releases/download/v1.3.0/microsoft-todo-electron-1.3.0.tar.gz";
    sha256 = "1n3sbw2xc9dqz6drnmdbjvkx8zxls60xmjlmfs07zxhm2a2amlp5";
  };
  
  unpackPhase = ''
    mkdir unzipped
    tar -xvzf ${src} -C unzipped
  '';

  installPhase = ''
    cp -r unzipped/* $out
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath ${rpath}:$out $out/microsoft-todo-electron
    echo `ldd $out/microsoft-todo-electron | grep "not found"` # echo for debug.
  '';
}
