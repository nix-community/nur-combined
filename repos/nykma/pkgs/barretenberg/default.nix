{ lib, llvmPackages_18, fetchgit,
  cmake, libdeflate, tree, ninja,
  cvc5, lmdb, tracy, gtest,
}:
let
  version = "0.87.4";
  hash = "sha256-2B+MjOjARtpJk28eKbKSJPnGXbdZ3rHz/spl7P8+cTE=";
  src = fetchgit {
    inherit hash;
    url = "https://github.com/AztecProtocol/aztec-packages.git";
    rev = "refs/tags/v${version}";
    sparseCheckout = [ "barretenberg/cpp" ];
  };
  benchmark = fetchgit {
    hash = "sha256-yiNrkDsJISKISLNGKbKKjJgCKFhvDvDhzuIZb2J5PDc=";
    url = "https://github.com/AztecProtocol/google-benchmark.git";
    rev = "7638387d2727853d970fc9420dcf95cf3e9bd112";
  };
  msgpack = fetchgit {
    hash = "sha256-kyb0ZiUe3qeRTSqt8LAJIjGBXI0dm2ULXbL0skt94qw=";
    url = "https://github.com/AztecProtocol/msgpack-c.git";
    rev = "5ee9a1c8c325658b29867829677c7eb79c433a98";
  };
  fetchContent = {name, package}: "-DFETCHCONTENT_SOURCE_DIR_${lib.toUpper name}=${package}";
in
llvmPackages_18.stdenv.mkDerivation {
  inherit version src;
  pname = "barretenberg";

  nativeBuildInputs = [cmake libdeflate tree ninja];
  buildInputs = [cvc5 lmdb tracy gtest];

  patches = [
    ./patches/msgpack.cmake.patch
    ./patches/lmdb.cmake.patch
  ];

  preConfigure = ''
  cd barretenberg/cpp
  mkdir -p build/_deps/msgpack-c/src
  cp -r ${msgpack}/* build/_deps/msgpack-c/src
  chmod -R 777 build/_deps/msgpack-c/src

  mkdir -p build/_deps/lmdb/src
  cp -r ${lmdb.src}/* build/_deps/lmdb/src
  chmod -R 777 build/_deps/lmdb/src
  '';

  buildPhase = ''
  runHook preBuild
  cd ..
  cmake --build --preset=default --target bb -j$NIX_BUILD_CORES
  runHook postBuild
  ls -lah build
  '';

  installPhase = ''
  runHook preInstall
  pwd
  cmake --install ./build
  runHook postInstall
  '';

  # buildFlags = ["--target=bb"];

  # preBuild = ''
  # cp -rp ${msgpack}/* /build/aztec-packages/barretenberg/cpp/build/_deps/msgpack-c/src
  # tree /build/aztec-packages/barretenberg/cpp/build/_deps/msgpack-c/src
  # '';

  cmakeFlags = [
    (fetchContent { name = "tracy"; package = tracy.src; })
    (fetchContent { name = "gtest"; package = gtest.src; })
    (fetchContent { name = "benchmark"; package = benchmark; })
    (fetchContent { name = "MSGPACK_C"; package = msgpack; })
    # (fetchContent { name = "lmdb"; package = lmdb.src; })
    "-DFETCHCONTENT_SOURCE_DIR_LMDB=/build/aztec-packages/barretenberg/cpp/build/_deps/lmdb/src"
    (fetchContent { name = "libdeflate"; package = libdeflate.src; })
    "--preset=default"
  ];

  meta = with lib; {
    description = "Barretenberg (or bb for short) is an optimized elliptic curve library for the bn128 curve, and a PLONK SNARK prover";
    homepage = "https://github.com/AztecProtocol/aztec-packages/tree/next/barretenberg";
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
