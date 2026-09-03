{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  boost,
  curl,
  fftw,
  fftwFloat,
  fftwLongDouble,
  ffmpeg,
  readline,
  ncurses,
  libuuid,
  libdrm,
  cargo,
  rustc,
  rustPlatform,
  autoPatchelfHook,
  xrt ? null,
}:
stdenv.mkDerivation {
  pname = "openflowlm";
  version = "0.1.0-dev";

  src = fetchFromGitHub {
    owner = "Atomic-Germ";
    repo = "OpenFlowLM";
    rev = "5f85719ba83d68c9c1442eb64e820849e251fc28";
    hash = "sha256-Avk1JiNciW02sUEa1lcTEs8o1BIKbJ6VFLLQI+XzHmQ=";
    fetchSubmodules = true;
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  cargoRoot = "third_party/tokenizers-cpp/rust";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    cargo
    rustc
    rustPlatform.cargoSetupHook
    autoPatchelfHook
  ];

  buildInputs = [
    boost
    curl
    fftw
    fftwFloat
    fftwLongDouble
    ffmpeg
    readline
    ncurses
    libuuid
    libdrm
    stdenv.cc.cc.lib
    xrt
  ];

  patches = [
    ./flm-test.patch
  ];

  postPatch =
    # bash
    ''
      cp ${./Cargo.lock} third_party/tokenizers-cpp/rust/Cargo.lock
    '';

  dontUseCmakeConfigure = true;

  configurePhase = let
    flmVersion = "1.0.4";
  in
    # bash
    ''
      runHook preConfigure
      cmake -S src -B src/build \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DFLM_VERSION="${flmVersion}" \
        -DNPU_VERSION="32.0.203.304" \
        "-DXRT_INCLUDE_DIR=${xrt}/opt/xilinx/xrt/include" \
        "-DXRT_LIB_DIR=${xrt}/opt/xilinx/xrt/lib" \
        -DCMAKE_INSTALL_PREFIX=$out \
        -DCMAKE_XCLBIN_PREFIX=$out/share/flm
      runHook postConfigure
    '';

  buildPhase =
    # bash
    ''
      runHook preBuild
      ninja -C src/build
      runHook postBuild
    '';

  installPhase =
    # bash
    ''
      runHook preInstall
      ninja -C src/build install
      runHook postInstall
    '';

  meta = {
    description = "A project to create a truly open community edition of FLM.";
    homepage = "https://github.com/Atomic-Germ/OpenFlowLM";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "flm";
    broken = xrt == null;
  };
}
