{
  copyDesktopItems,
  fetchFromGitHub,
  makeDesktopItem,
  makeWrapper,
  imagemagick,
  sm64baserom,
  pkg-config,
  libxrandr,
  python3,
  libusb1,
  hexdump,
  stdenv,
  libx11,
  libGL,
  SDL2,
  lib,
}: let
  version = "0-unstable-2026-03-11";
  rev = "44fccee2fc4bd4768ae4eff1e5c47b21abe5d85d";

  baserom =
    (sm64baserom.override {
      region = "us";
      showRegionMessage = false;
    }).romPath;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "sm64plus";
    inherit version;

    src = fetchFromGitHub {
      owner = "MorsGames";
      repo = "sm64plus";
      inherit rev;
      hash = "sha256-hFYzT7QzRL87dral2E/K+zyBeAtK2i4d6Dk4Lt5ii2I=";
    };

    nativeBuildInputs = [
      copyDesktopItems
      makeWrapper
      imagemagick
      pkg-config
      python3
      hexdump
    ];

    buildInputs = [
      libxrandr
      libusb1
      libx11
      libGL
      SDL2
    ];

    desktopItems = [
      (makeDesktopItem {
        name = "sm64plus";
        desktopName = "SM64 Plus";
        comment = "Fork of SM64 Desktop with improvements";
        exec = "sm64plus";
        icon = "sm64plus";
        categories = ["Game"];
      })
    ];

    enableParallelBuilding = true;

    hardeningDisable = ["fortify"];

    preBuild = ''
            patchShebangs extract_assets.py tools
            substituteInPlace src/pc/gfx/gfx_opengl.c \
              --replace-fail '#include <SDL2/SDL_opengles2.h>' '#include <SDL2/SDL_opengl.h>
      #include <SDL2/SDL_opengles2.h>'
            ln -s ${baserom} ./baserom.us.z64
    '';

    installPhase = ''
      runHook preInstall

      local built=$PWD/build/us_pc
      local share=$out/share/sm64plus
      mkdir -p $share
      cp -r $built/. $share/

      magick "${finalAttrs.src}/star.ico[1]" icon.png
      for size in 16 24 32 48 64 128 256 512; do
        mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
        magick icon.png -resize "$size"x"$size" $out/share/icons/hicolor/"$size"x"$size"/apps/sm64plus.png
      done

      mkdir -p $out/bin
      makeWrapper $share/sm64.us $out/bin/sm64plus \
        --chdir $share

      runHook postInstall
    '';

    meta = {
      description = "A standalone fork of the Super Mario 64 PC port with quality of life improvements";
      homepage = "https://github.com/MorsGames/sm64plus";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [Prinky];
      platforms = lib.platforms.linux;
      mainProgram = "sm64plus";
    };
  })
