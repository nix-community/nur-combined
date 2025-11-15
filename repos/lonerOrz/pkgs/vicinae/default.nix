{
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  kdePackages,
  rapidfuzz-cpp,
  protobuf,
  grpc-tools,
  nodejs,
  minizip-ng,
  cmark-gfm,
  libqalculate,
  ninja,
  lib,
  fetchNpmDeps,
  protoc-gen-js,
  rsync,
  which,
  autoPatchelfHook,
  writeShellScriptBin,
  minizip,
  qt6,
  typescript,
  wayland,
}:

let
  pname = "vicinae";
  version = "0.16.6";

  srcHash = "sha256-mpZj5Nw/rKr97pATMLzO6RlTlag/ZJyvP/Mh6Ifmv2A=";
  apiDepsHash = "sha256-4OgVCnw5th2TcXszVY5G9ENr3/Y/eR2Kd45DbUhQRNk=";
  extensionManagerDepsHash = "sha256-krDFHTG8irgVk4a79LMz148drLgy2oxEoHCKRpur1R4=";

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
stdenv.mkDerivation (finalAttrs: {
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
    ts-protoc-gen-wrapper
    extensionManagerDeps
    autoPatchelfHook
    cmake
    ninja
    nodejs
    pkg-config
    qt6.wrapQtAppsHook
    rapidfuzz-cpp
    protoc-gen-js
    protobuf
    grpc-tools
    which
    rsync
    typescript
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qttools
    qt6.qtwayland
    qt6.qtdeclarative
    qt6.qt5compat
    wayland
    kdePackages.qtkeychain
    kdePackages.layer-shell-qt
    minizip
    grpc-tools
    protobuf
    nodejs
    minizip-ng
    cmark-gfm
    libqalculate
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
