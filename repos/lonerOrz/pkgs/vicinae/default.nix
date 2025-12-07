{
  gcc15Stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  kdePackages,
  protobuf,
  nodejs,
  cmark-gfm,
  libqalculate,
  ninja,
  lib,
  fetchNpmDeps,
  writeShellScriptBin,
  minizip,
  qt6,
  abseil-cpp,
  wayland,
  libxml2,
}:

let
  pname = "vicinae";
  version = "0.16.13";

  srcHash = "sha256-OIpOC69I+2rhIvIU2CmDXsKU4BRCouBGPlKx+IYFqOE=";
  apiDepsHash = "sha256-UsTpMR23UQBRseRo33nbT6z/UCjZByryWfn2AQSgm6U=";
  extensionManagerDepsHash = "sha256-wl8FDFB6Vl1zD0/s2EbU6l1KX4rwUW6dOZof4ebMMO8=";

  src = fetchFromGitHub {
    owner = "vicinaehq";
    repo = "vicinae";
    tag = "v${version}";
    sha256 = "${srcHash}";
  };

  # Prepare node_modules for api folder
  apiDeps = fetchNpmDeps {
    src = src + /typescript/api;
    hash = "${apiDepsHash}";
  };

  ts-protoc-gen-wrapper = writeShellScriptBin "protoc-gen-ts_proto" ''
    exec node ${src}/typescript/api/node_modules/.bin/protoc-gen-ts_proto
  '';

  # Prepare node_modules for extension-manager folder
  extensionManagerDeps = fetchNpmDeps {
    src = src + /typescript/extension-manager;
    hash = "${extensionManagerDepsHash}";
  };
in
gcc15Stdenv.mkDerivation (finalAttrs: {
  inherit pname version src;

  cmakeFlags = [
    "-DVICINAE_GIT_TAG=${finalAttrs.version}"
    "-DVICINAE_GIT_COMMIT_HASH=${builtins.substring 0 7 finalAttrs.src.rev}"
    "-DINSTALL_NODE_MODULES=OFF"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DCMAKE_INSTALL_DATAROOTDIR=share"
    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON" # LTO
  ];

  NIX_CFLAGS_COMPILE = "-O3 -march=native -mtune=native"; # native

  nativeBuildInputs = [
    cmake
    ninja
    nodejs
    pkg-config
    protobuf
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    abseil-cpp
    cmark-gfm
    kdePackages.layer-shell-qt
    kdePackages.qtkeychain
    libqalculate
    minizip
    nodejs
    protobuf
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
    wayland
    libxml2
  ];

  configurePhase = ''
    cmake -G Ninja -B build $cmakeFlags
  '';

  buildPhase = ''
    buildDir=$PWD
    export npm_config_cache=${apiDeps}
    cd $buildDir/typescript/api
    npm i --ignore-scripts
    patchShebangs $buildDir/typescript/api
    npm rebuild --foreground-scripts

    export npm_config_cache=${extensionManagerDeps}
    cd $buildDir/typescript/extension-manager
    npm i --ignore-scripts
    patchShebangs $buildDir/typescript/extension-manager
    npm rebuild --foreground-scripts

    cd $buildDir
    cmake --build build
  '';

  dontWrapQtApps = true;

  preFixup = ''
    wrapQtApp "$out/bin/vicinae" --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath finalAttrs.buildInputs}
  '';

  postFixup = ''
    wrapProgram $out/bin/vicinae \
      --prefix PATH : ${
        lib.makeBinPath [
          nodejs
          qt6.qtwayland
          wayland
          (placeholder "out")
        ]
      }
  '';

  installPhase = ''
    cmake --install build
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "A focused launcher for your desktop — native, fast, extensible";
    homepage = "https://github.com/vicinaehq/vicinae";
    license = licenses.gpl3Plus;
    mainProgram = "vicinae";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
