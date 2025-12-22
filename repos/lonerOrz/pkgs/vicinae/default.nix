{
  gcc15Stdenv,
  fetchFromGitHub,
  cmake,
  glaze,
  pkg-config,
  kdePackages,
  protobuf,
  nodejs,
  npmHooks,
  cmark-gfm,
  libqalculate,
  ninja,
  lib,
  fetchNpmDeps,
  minizip,
  qt6,
  abseil-cpp,
  wayland,
  libxml2,
}:

let
  pname = "vicinae";
  version = "0.17.0";

  srcHash = "sha256-r7igMwLdNgAkVDLporW4IKCjUWnIvYY2PWbwQPfaJ9o=";
  apiDepsHash = "sha256-UsTpMR23UQBRseRo33nbT6z/UCjZByryWfn2AQSgm6U=";
  extensionManagerDepsHash = "sha256-wl8FDFB6Vl1zD0/s2EbU6l1KX4rwUW6dOZof4ebMMO8=";

  src = fetchFromGitHub {
    owner = "vicinaehq";
    repo = "vicinae";
    tag = "v${version}";
    sha256 = "${srcHash}";
  };

  apiDeps = fetchNpmDeps {
    src = src + /typescript/api;
    hash = "${apiDepsHash}";
  };

  extensionManagerDeps = fetchNpmDeps {
    src = src + /typescript/extension-manager;
    hash = "${extensionManagerDepsHash}";
  };
in
gcc15Stdenv.mkDerivation (finalAttrs: {
  inherit pname version src;

  cmakeFlags = lib.mapAttrsToList lib.cmakeFeature {
    "VICINAE_GIT_TAG" = "v${finalAttrs.version}";
    "VICINAE_PROVENANCE" = "nix";
    "INSTALL_NODE_MODULES" = "OFF";
    "USE_SYSTEM_GLAZE" = "ON";
    "CMAKE_INSTALL_PREFIX" = placeholder "out";
    "CMAKE_INSTALL_DATAROOTDIR" = "share";
    "CMAKE_INSTALL_BINDIR" = "bin";
    "CMAKE_INSTALL_LIBDIR" = "lib";
    "DCMAKE_INTERPROCEDURAL_OPTIMIZATION" = "ON"; # LTO
  };

  NIX_CFLAGS_COMPILE = "-O3 -march=native -mtune=native"; # native

  strictDeps = true;

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
    glaze
  ];

  postPatch = ''
    local postPatchHooks=()
    source ${npmHooks.npmConfigHook}/nix-support/setup-hook
    npmRoot=typescript/api npmDeps=${apiDeps} npmConfigHook
    npmRoot=typescript/extension-manager npmDeps=${extensionManagerDeps} npmConfigHook
  '';

  qtWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        nodejs
        (placeholder "out")
      ]
    }"
  ];

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
