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
  clang,
  lld,
  which,
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
  ];
in
stdenv.mkDerivation {
  pname = "vita3k";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Vita3k";
    repo = "Vita3k";
    rev = "3ef6220197d76a96c5f4869c86b2489d25080191";
    fetchSubmodules = true;
    hash = "sha256-PmHW3n0YXqwzjQt5d0h9rmEymue5EEvAXhKcPTKgJ/M=";
  };

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    makeWrapper
    pkg-config
    git
    ninja
    clang
    lld
    which
  ];

  buildInputs = libs;

  postPatch = ''
    mkdir -p build/linux-ninja-clang/external 
    cp ${vita3k-ffmpeg} build/linux-ninja-clang/external/ffmpeg.zip
    substituteInPlace external/boost/tools/build/src/engine/build.sh --replace-fail '#!/usr/bin/env sh' '#!/bin/sh'
  '';

  dontUseCmakeConfigure = true;
  buildPhase = ''
    pwd
    cmake --preset linux-ninja-clang
    cmake --build build/linux-ninja-clang --preset linux-ninja-clang-relwithdebinfo
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "Vita3k";
      name = "Vita3k";
      exec = "vita3k";
      icon = "Vita3k";
      comment = "Vita3k (PSV emulator)";
      categories = [ "Game" "Emulator" ];
    })
  ];

  installPhase =''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/vita3k
    install -Dm555 build/linux-ninja-clang/bin/RelWithDebInfo/Vita3K $out/share/vita3k/Vita3k
    mv build/linux-ninja-clang/bin/RelWithDebInfo/data $out/share/vita3k/data
    mv build/linux-ninja-clang/bin/RelWithDebInfo/lang $out/share/vita3k/lang
    mv build/linux-ninja-clang/bin/RelWithDebInfo/shaders-builtin $out/share/vita3k/shaders-builtin
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
