{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  SDL2,
  libGL,
  openal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lain-psx-decompiled";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Y0oshi";
    repo = "lain-psx-decompiled";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SLcpsrRZC/5Z2oMbBWsfr0N61+DxxpNXeuO8nTNtZgs=";
  };

  # port/ is the native client: the decompiled game (port/game) compiled for
  # the host against PsyCross, which reimplements the PlayStation SDK on SDL2,
  # OpenGL and OpenAL. The top-level Makefile builds the byte-identical PSX
  # executable instead, and needs the PsyQ toolchain and the discs.
  dontConfigure = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    SDL2
    openal
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux libGL;

  buildPhase = ''
    runHook preBuild

    # Release passes link SDL2 and openal-soft statically from FetchContent;
    # the nixpkgs ones are used instead, so nothing is fetched here.
    # PsyCross formats a string built from a variable in two places, which
    # clang 21 rejects under the project's -Werror; the warning stays visible.
    cmake -S port -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DLAIN_STATIC_DEPS=OFF \
      -DCMAKE_CXX_FLAGS=-Wno-error=format-security \
      -DPython3_EXECUTABLE=${python3}/bin/python3

    cmake --build build --target lain -j''${NIX_BUILD_CORES:-1}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/lain "$out/bin/lain"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Native client for the Serial Experiments Lain (PlayStation) decompilation";
    longDescription = ''
      A decompilation of Serial Experiments Lain for the PlayStation, and a
      native client built from it: the reconstructed C code runs on PsyCross, a
      reimplementation of the PlayStation SDK, instead of an emulator. No game
      data is included. The client verifies and imports your own Redump dumps
      of disc 1 (SLPS-01603) and disc 2 (SLPS-01604) on first start and keeps
      them, the memory card and settings in the platform's application data
      directory.
    '';
    homepage = "https://github.com/Y0oshi/lain-psx-decompiled";
    changelog = "https://github.com/Y0oshi/lain-psx-decompiled/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "lain";
  };
})
