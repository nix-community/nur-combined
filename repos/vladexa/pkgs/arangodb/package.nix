{
  # gcc 11.2 suggested on 3.10.5.2.
  # gcc 11.3.0 unsupported yet, investigate gcc support when upgrading
  # See https://github.com/arangodb/arangodb/issues/17454
  stdenv,
  git,
  lib,
  fetchFromGitHub,
  openssl,
  zlib,
  cmake,
  python3,
  perl,
  snappy,
  lzo,
  which,
  targetArchitecture ? null,
  asmOptimizations ? stdenv.targetPlatform.isx86,
}:

let
  defaultTargetArchitecture = if stdenv.targetPlatform.isx86 then "haswell" else "core";

  targetArch = if targetArchitecture == null then defaultTargetArchitecture else targetArchitecture;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "arangodb";
  version = "3.10.14";

  src = fetchFromGitHub {
    repo = "arangodb";
    owner = "arangodb";
    tag = "v${finalAttrs.version}";
    # rev = "31b0e460c1f941f939b5fbd07d49989e75c75083";
    hash = "sha256-KYVu6cdeuYlQ554oYel64TXfH9lqL82LbEdINcOtm0E=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    git
    perl
    python3
    which
  ];

  buildInputs = [
    openssl
    zlib
    snappy
    lzo
  ];

  # prevent failing with "cmake-3.13.4/nix-support/setup-hook: line 10: ./3rdParty/rocksdb/RocksDBConfig.cmake.in: No such file or directory"
  dontFixCmake = true;
  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  enableParallelBuilding = true;

  postPatch = ''
    sed -i -e 's!/bin/echo!echo!' 3rdParty/V8/gypfiles/*.gypi

    # with nixpkgs, it has no sense to check for a version update
    substituteInPlace js/client/client.js --replace "require('@arangodb').checkAvailableVersions();" ""
    substituteInPlace js/server/server.js --replace "require('@arangodb').checkAvailableVersions();" ""
  '';

  preConfigure = ''
    patchShebangs utils
  '';

  cmakeBuildType = "RelWithDebInfo";

  cmakeFlags = [
    "-DUSE_MAINTAINER_MODE=OFF"
    "-DUSE_GOOGLE_TESTS=OFF"

    # avoid reading /proc/cpuinfo for feature detection
    "-DTARGET_ARCHITECTURE=${targetArch}"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ]
  ++ lib.optionals asmOptimizations [
    "-DASM_OPTIMIZATIONS=ON"
    "-DHAVE_SSE42=${if stdenv.targetPlatform.sse4_2Support then "ON" else "OFF"}"
  ];

  meta = with lib; {
    homepage = "https://www.arangodb.com";
    description = "Native multi-model database with flexible data models for documents, graphs, and key-values";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    maintainers = [
      {
        email = "vgrechannik@gmail.com";
        name = "Vladislav Grechannik";
        github = "VlaDexa";
        githubId = 52157081;
      }
    ];
  };
})
