{
  lib,
  llvmPackages_20,
  fetchFromGitHub,
  fetchzip,
  cmake,
  ninja,
  python3,
  pkg-config,
  zlib,
  zstd,
  libxml2,
  ncurses,
  libffi,
}:

# Upstream CI builds with Clang 20; GCC 15 ICEs on kotatsu C++23 async code.
let
  inherit (llvmPackages_20) stdenv;

  # Matches cmake/package.cmake setup_llvm(...). Distro LLVM lacks the private
  # Clang headers clice needs, so we use the project's published prebuilts.
  llvmVersion = "21.1.8+r1";

  llvmArtifact =
    if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64 then
      {
        name = "x64-linux-gnu-releasedbg";
        hash = "sha256-QAHT5iYnLmJxSQQ0cN56GQcdyjScMhfoHoKciNzUiPU=";
      }
    else if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64 then
      {
        name = "arm64-linux-gnu-releasedbg";
        hash = "sha256-8LC5n54Unh5IiYBFT8pa14SDbv55urL27K/BR00rDcY=";
      }
    else
      throw "clice: unsupported platform ${stdenv.hostPlatform.system}";

  clice-llvm = fetchzip {
    url = "https://github.com/clice-io/clice-llvm/releases/download/${
      lib.replaceStrings [ "+" ] [ "%2B" ] llvmVersion
    }/${llvmArtifact.name}.tar.xz";
    hash = llvmArtifact.hash;
    stripRoot = false;
  };

  # Vendored FetchContent deps (cmake/package.cmake + kotatsu nested deps).
  spdlogSrc = fetchFromGitHub {
    owner = "gabime";
    repo = "spdlog";
    tag = "v1.15.3";
    hash = "sha256-0rOR9G2Y4Z4OBZtUHxID0s1aXN9ejodHrurlVCA0pIo=";
  };

  croaringSrc = fetchFromGitHub {
    owner = "RoaringBitmap";
    repo = "CRoaring";
    tag = "v4.4.2";
    hash = "sha256-ACFcbg+IdpRIQlqsqb1wtIT+N7zOW9fR+faDajSUM8c=";
  };

  flatbuffersSrc = fetchFromGitHub {
    owner = "google";
    repo = "flatbuffers";
    tag = "v25.9.23";
    hash = "sha256-A9nWfgcuVW3x9MDFeviCUK/oGcWJQwadI8LqNR8BlQw=";
  };

  kotatsuSrc = fetchFromGitHub {
    owner = "clice-io";
    repo = "kotatsu";
    rev = "f2cdf651e2b9121a8aab64e0ba64aa3011c74712";
    hash = "sha256-+YuZW8dTQW6XgwyrooR9NfvUYpDkS9/LUmqywcZ6GgE=";
  };

  simdjsonSrc = fetchFromGitHub {
    owner = "simdjson";
    repo = "simdjson";
    tag = "v4.2.4";
    hash = "sha256-TTZcdnD7XT5n39n7rSlA81P3pid+5ek0noxjXAGbb64=";
  };

  tomlplusplusSrc = fetchFromGitHub {
    owner = "marzer";
    repo = "tomlplusplus";
    tag = "v3.4.0";
    hash = "sha256-h5tbO0Rv2tZezY58yUbyRVpsfRjY3i+5TPkkxr6La8M=";
  };

  libuvSrc = fetchFromGitHub {
    owner = "libuv";
    repo = "libuv";
    tag = "v1.52.0";
    hash = "sha256-WyIBJjxsGo1sSjmbM1zRBF2cR97n6iSBK12FGbg73n0=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "clice";
  version = "0.1.2026072305";

  src = fetchFromGitHub {
    owner = "clice-io";
    repo = "clice";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UEabIK91vQPu2i8ln/HUrGVVu012qoLtcMHh4KuvygM=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3
    pkg-config
  ];

  buildInputs = [
    zlib
    zstd
    libxml2
    ncurses
    libffi
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'project(CLICE_PROJECT VERSION 0.1.0' \
      'project(CLICE_PROJECT VERSION ${finalAttrs.version}'

    # zest/cpptrace only needed for unit tests; skip the nested download.
    substituteInPlace cmake/package.cmake \
      --replace-fail 'set(KOTA_ENABLE_ZEST ON)' 'set(KOTA_ENABLE_ZEST OFF)'
  ''
  # Upstream ships -static-libstdc++/-static-libgcc for portable release
  # tarballs; Nix links against the stdenv runtime instead.
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace CMakeLists.txt \
      --replace-fail ' -static-libstdc++ -static-libgcc' ""
  '';

  # FetchContent sources must be writable (CRoaring configure_file, etc.).
  preConfigure = ''
    mkdir -p "$NIX_BUILD_TOP/deps"
    cp -a --no-preserve=mode ${spdlogSrc} "$NIX_BUILD_TOP/deps/spdlog"
    cp -a --no-preserve=mode ${croaringSrc} "$NIX_BUILD_TOP/deps/croaring"
    cp -a --no-preserve=mode ${flatbuffersSrc} "$NIX_BUILD_TOP/deps/flatbuffers"
    cp -a --no-preserve=mode ${kotatsuSrc} "$NIX_BUILD_TOP/deps/kotatsu"
    cp -a --no-preserve=mode ${simdjsonSrc} "$NIX_BUILD_TOP/deps/simdjson"
    cp -a --no-preserve=mode ${tomlplusplusSrc} "$NIX_BUILD_TOP/deps/tomlplusplus"
    cp -a --no-preserve=mode ${libuvSrc} "$NIX_BUILD_TOP/deps/libuv"

    cmakeFlags+=" -DFETCHCONTENT_SOURCE_DIR_SPDLOG=$NIX_BUILD_TOP/deps/spdlog"
    cmakeFlags+=" -DFETCHCONTENT_SOURCE_DIR_CROARING=$NIX_BUILD_TOP/deps/croaring"
    cmakeFlags+=" -DFETCHCONTENT_SOURCE_DIR_FLATBUFFERS=$NIX_BUILD_TOP/deps/flatbuffers"
    cmakeFlags+=" -DFETCHCONTENT_SOURCE_DIR_KOTATSU=$NIX_BUILD_TOP/deps/kotatsu"
    cmakeFlags+=" -DFETCHCONTENT_SOURCE_DIR_SIMDJSON=$NIX_BUILD_TOP/deps/simdjson"
    cmakeFlags+=" -DFETCHCONTENT_SOURCE_DIR_TOMLPLUSPLUS=$NIX_BUILD_TOP/deps/tomlplusplus"
    cmakeFlags+=" -DFETCHCONTENT_SOURCE_DIR_LIBUV=$NIX_BUILD_TOP/deps/libuv"
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCLICE_OFFLINE_BUILD=ON"
    "-DCLICE_ENABLE_TEST=OFF"
    "-DCLICE_ENABLE_BENCHMARK=OFF"
    "-DROARING_USE_CPM=OFF"
    "-DLLVM_INSTALL_PATH=${clice-llvm}"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
  ];

  # Linking static LLVM/Clang is memory-heavy.
  enableParallelBuilding = true;

  # FetchContent deps (CRoaring/flatbuffers) register install rules that leak
  # into $out (broken roaring.pc, flatc). Keep only clice + clang resources.
  preFixup = ''
    rm -rf "$out/lib/pkgconfig" "$out/lib/cmake" "$out/include"
    rm -f "$out/bin/flatc"
    rm -f "$out"/lib/libroaring* "$out"/lib/libflatbuffers* || true
  '';

  meta = {
    description = "Next-generation C++ language server built on LLVM/Clang";
    homepage = "https://github.com/clice-io/clice";
    changelog = "https://docs.clice.io/clice/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "clice";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
