{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
  libarchive,
  runCommand,
  libgcc,
  libGL,
  openal,
  libmpg123,
  libxmp,
  libsndfile,
  wayland,
  libx11,
  libxkbcommon,
  libdecor,
  nix-update-script,
}:

let
  version = "227k_14";
  src = fetchurl {
    url = "https://github.com/OldUnreal/Unreal-testing/releases/download/v${version}/OldUnreal-UnrealPatch227k-Linux.tar.bz2";
    hash = "sha256-lVADQ8C8RXqncGO8bvuvgweXm9ALbqPUCGzifF0HD40=";
  };

  gameData =
    runCommand "unreal-gold-data"
      {
        src = fetchurl {
          # https://files.oldunreal.net/UNREAL_GOLD.ISO
          url = "https://archive.org/download/totallyunreal/UNREAL_GOLD.ISO";
          hash = "sha256-fjYNDMnlUz84hZgZ/Ty/6nxHXs1Cj59DO1+OHVdCy8o=";
        };
        nativeBuildInputs = [ libarchive ];
      }
      ''
        bsdtar -xvf "$src"
        mkdir -p $out/System
        cp -r MAPS $out/Maps
        cp -r SOUNDS $out/Sounds
        cp -r MUSIC $out/Music
        cp -r TEXTURES $out/Textures
        cp -n SYSTEM/*.{u,int} $out/System/ || true
      '';

  runtimeDataDirs = [
    "Maps"
    "Music"
    "Sounds"
    "Textures"
    "Meshes"
    "SystemLocalized"
    "Help"
    "Compress"
    "WebServer"
  ];

  runtimeLibraryPath = lib.makeLibraryPath [
    libgcc
    stdenv.cc.cc
    libGL
    wayland
    libx11
    libxkbcommon
    libdecor
  ];
in
stdenv.mkDerivation (_finalAttrs: {
  pname = "unreal-gold";
  inherit version;
  sourceRoot = ".";
  inherit src;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    libgcc
    libGL
    openal
    libmpg123
    libxmp
    libsndfile
    wayland
    libx11
    libxkbcommon
    libdecor
    stdenv.cc.cc
  ];

  installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp -r ./* $out
        chmod -R 755 $out
        cd $out

        cp -a $out/System/*.{u,int} $out/System64/ || true
        rm -rf $out/System $out/SystemARM64
        mv $out/System64 $out/System

        cp -rn ${gameData}/Maps ./ 2>/dev/null || true
        cp -rn ${gameData}/Textures ./ 2>/dev/null || true
        cp -rn ${gameData}/Sounds ./ 2>/dev/null || true
        cp -rn ${gameData}/Music ./ 2>/dev/null || true
        cp -n ${gameData}/System/*.{u,int} ./System || true
        rm -f $out/System/libmpg123.so* \
          $out/System/libopenal.so* \
          $out/System/libxmp.so* \
          $out/System/libsndfile.so*

        rm -f "$out/bin/unreal-gold"
        cat > "$out/bin/unreal-gold" << WRAPPER
    #!/usr/bin/env bash
    set -eu
    STORE="$out"
    RUNTIME_DIR="\$HOME/.local/share/unreal-gold"

    mkdir -p "\$RUNTIME_DIR"

    for d in ${lib.concatStringsSep " " runtimeDataDirs}; do
      if [ -d "\$STORE/\$d" ]; then
        ln -snf "\$STORE/\$d" "\$RUNTIME_DIR/\$d"
      fi
    done


    if [ -d "\$STORE/System" ]; then
      mkdir -p "\$RUNTIME_DIR/System"
      cp -rn "\$STORE/System/." "\$RUNTIME_DIR/System/"
    fi

    cd "\$RUNTIME_DIR"
    export LD_LIBRARY_PATH="\$RUNTIME_DIR/System:${runtimeLibraryPath}"
    exec "\$RUNTIME_DIR/System/unreal-bin-amd64" "\$@"
    WRAPPER
        chmod +x "$out/bin/unreal-gold"
        install -D "${./unreal-gold.svg}" "$out/share/icons/hicolor/scalable/apps/unreal-gold.svg"
        runHook postInstall
  '';

  appendRunpaths = [ "${placeholder "out"}/System" ];

  desktopItems = [
    (makeDesktopItem {
      name = "unreal-gold";
      desktopName = "Unreal Gold";
      exec = "unreal-gold";
      icon = "unreal-gold";
      comment = "Unreal Gold — classic first-person shooter, with the OldUnreal 227 community patch";
      categories = [
        "Game"
        "ActionGame"
      ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unreal Gold — classic first-person shooter, with the OldUnreal 227 community patch";
    homepage = "https://www.oldunreal.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
    mainProgram = "unreal-gold";
  };
})
