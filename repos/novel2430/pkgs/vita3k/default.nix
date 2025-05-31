{
  lib,
  SDL2,
  cmake,
  copyDesktopItems,
  fetchFromGitHub,
  fetchurl,
  makeDesktopItem,
  makeWrapper,
  pkg-config,
  stdenv,
  vulkan-loader,
  zlib,
  openssl,
  dbus,
  curl,
  git,
  ninja,
  gcc,
  which,
  xorg,
}:
let
  vita3k-ffmpeg = fetchurl {
    url = "https://github.com/Vita3K/ffmpeg-core/releases/download/434b71f/ffmpeg-linux-x64.zip";
    hash = "sha256-0az7TO1iIMMsCWW5Jotb32AlLGp0URG6L7pKZKh3sVY=";
  };
  libs = [
    SDL2
    zlib
    openssl
    dbus
    curl
    vulkan-loader
    xorg.libX11
  ];
in
stdenv.mkDerivation {
  pname = "vita3k";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Vita3k";
    repo = "Vita3k";
    rev = "e70f38e0129c4b48b12a7aefee4121652d7315b2";
    fetchSubmodules = true;
    hash = "sha256-GIObVkW/vmP7nBUZ7dzL3GWnGQif4SR5aSPuHzuwGas=";
  };

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    makeWrapper
    pkg-config
    git
    ninja
    gcc
    which
  ];

  buildInputs = libs;

  postPatch = ''
    mkdir -p build/linux-ninja-gnu/external 
    cp ${vita3k-ffmpeg} build/linux-ninja-gnu/external/ffmpeg.zip
    substituteInPlace external/boost/tools/build/src/engine/build.sh --replace-fail '#!/usr/bin/env sh' '#!/bin/sh'
  '';

  dontUseCmakeConfigure = true;
  buildPhase = ''
    cmake --preset linux-ninja-gnu
    cmake --build build/linux-ninja-gnu --preset linux-ninja-gnu-relwithdebinfo
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "Vita3k";
      name = "Vita3k";
      exec = "vita3k";
      icon = "Vita3k";
      comment = "Vita3k (PSV emulator)";
      categories = [ "Game" "Emulator" ];
      keywords = ["Sony" "PlayStation" "PSV" "handheld"];
    })
  ];

  installPhase =''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/vita3k
    install -Dm555 build/linux-ninja-gnu/bin/RelWithDebInfo/Vita3K $out/share/vita3k/Vita3k
    mv build/linux-ninja-gnu/bin/RelWithDebInfo/data $out/share/vita3k/data
    mv build/linux-ninja-gnu/bin/RelWithDebInfo/lang $out/share/vita3k/lang
    mv build/linux-ninja-gnu/bin/RelWithDebInfo/shaders-builtin $out/share/vita3k/shaders-builtin
    install -Dm644 \
        $out/share/vita3k/data/image/icon.png \
        $out/share/icons/hicolor/128x128/apps/Vita3k.png
    makeWrapper $out/share/vita3k/Vita3k $out/bin/vita3k \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath libs};
    runHook postInstall
  '';

  postFixup = ''
  '';

  meta = {
    homepage = "https://vita3k.org/";
    description = "Experimental PlayStation Vita emulator";
    longDescription = ''
      Vita3K is the world's first functional experimental open-source PlayStation Vita emulator
        for Windows, Linux, macOS and Android.
      Please note that the purpose of the emulator is not to enable illegal activity.
    '';
    license = lib.licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
  };
}
