##########################################################################
#                                                                        #
#  This file is part of the elzorrorebelde/nur project                   #
#                                                                        #
#  Copyright (C) 2026 Jorge Javier Araya Navarro                         #
#                                                                        #
#  SPDX-License-Identifier: MIT                                          #
#                                                                        #
##########################################################################

{
  lib,
  stdenv,
  fetchFromGitHub,
  typescript,
  nodejs,
  makeWrapper,
  python3,
  util-linux,
  libnotify,
  cmake,
  ninja,
  pkg-config,
  libepoxy,
  vulkan-headers,
  wayland,
  libdrm,
  kdePackages,
  withEffects ? lib.versionAtLeast kdePackages.kwin.version "6.7",
}:

let
  inherit (kdePackages)
    kwin
    kcoreaddons
    kconfig
    kconfigwidgets
    kcmutils
    qtbase
    qtdeclarative
    qttools
    kpackage
    kservice
    extra-cmake-modules
    ;

  runtimeDeps = [
    qttools
    kconfig
    kpackage
    kservice
    libnotify
    python3
    util-linux
  ];
in
assert !withEffects || lib.versionAtLeast kwin.version "6.7";
stdenv.mkDerivation (finalAttrs: {
  pname = "kiri";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "SeniorMatt";
    repo = "kiri";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jeoJuYQ6dnzDLEiLU+96HOhLa61cnja/vo+k7sHnw3M=";
  };

  nativeBuildInputs = [
    kpackage
    kwin
    typescript
    nodejs
    makeWrapper
    python3
  ] ++ lib.optionals withEffects [
    cmake
    ninja
    pkg-config
    extra-cmake-modules
    qttools
  ];

  buildInputs = lib.optionals withEffects [
    kwin
    kcoreaddons
    kconfig
    kconfigwidgets
    kcmutils
    qtbase
    qtdeclarative
    libepoxy
    vulkan-headers
    wayland
    libdrm
  ];

  dontWrapQtApps = true;

  postPatch = ''
    patchShebangs tools/kiri-mode tools/niri2kiri.py
  '' + lib.optionalString (!withEffects) ''
    substituteInPlace package/metadata.json \
      --replace-fail '"X-KDE-ConfigModule": "kwin/effects/configs/kcm_kiri"' \
                     '"X-KDE-ConfigModule": "kwin/effects/configs/kcm_kwin4_genericscripted"'
  '';

  configurePhase = ":";

  buildPhase = ''
    runHook preBuild
    mkdir -p package/contents/code package/contents/config
    tsc -p ./src/main --outFile ./package/contents/code/main.js
    tsc -p ./src/generators/config --outFile ./gen-config.js
    node ./gen-config.js > ./package/contents/config/main.xml
  '' + lib.optionalString withEffects ''
    cmake -S ./effect-cpp -B ./build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$out \
      -DKDE_INSTALL_QTPLUGINDIR=$out/lib/qt-6/plugins
    cmake --build ./build
  '' + ''
    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    tsc -p ./src/tests --outFile ./tests.js
    node ./tests.js ""
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/kwin/scripts $out/share/kwin/effects
    kpackagetool6 --type=KWin/Script --install=./package --packageroot=$out/share/kwin/scripts
  '' + lib.optionalString (!withEffects) ''
    kpackagetool6 --type=KWin/Effect --install=./effect --packageroot=$out/share/kwin/effects
  '' + lib.optionalString withEffects ''
    cmake --install ./build
  '' + ''
    install -Dm755 tools/kiri-mode $out/bin/kiri-mode
    install -Dm755 tools/niri2kiri.py $out/share/kiri/tools/niri2kiri.py
    install -Dm644 src/lib/config/definition.ts $out/share/kiri/src/lib/config/definition.ts
    makeWrapper ${python3}/bin/python3 $out/bin/niri2kiri \
      --add-flags $out/share/kiri/tools/niri2kiri.py \
      --prefix PATH : ${lib.makeBinPath runtimeDeps}
    wrapProgram $out/bin/kiri-mode --prefix PATH : ${lib.makeBinPath runtimeDeps}
    runHook postInstall
  '';

  meta = {
    description = "Scrollable tiling KWin script in the style of niri";
    longDescription = ''
      Kiri is a KWin script that tiles windows in columns on an endless
      horizontal strip, like niri. It is a fork of Karousel and supports
      multiple monitors, dynamic desktops and the Kiri/Plasma mode switch.
    '';
    homepage = "https://github.com/SeniorMatt/kiri";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ elzorrorebelde ];
    platforms = lib.platforms.linux;
    mainProgram = "kiri-mode";
  };
})
