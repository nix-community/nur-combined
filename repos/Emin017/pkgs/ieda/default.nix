{
  lib,
  stdenv,
  fetchgit,
  fetchFromGitHub,
  fetchpatch,
  callPackages,
  cmake,
  ninja,
  flex,
  bison,
  zlib,
  tcl,
  boost,
  eigen,
  yaml-cpp,
  libunwind,
  glog,
  gtest,
  gflags,
  metis,
  gmp,
  python3,
  onnxruntime,
}:
let
  glog' = glog.overrideAttrs (oldAttrs: rec {
    version = "0.6.0";
    src = fetchFromGitHub {
      owner = "google";
      repo = "glog";
      rev = "v${version}";
      sha256 = "sha256-xqRp9vaauBkKz2CXbh/Z4TWqhaUtqfbsSlbYZR/kW9s=";
    };
  });
  rootSrc = stdenv.mkDerivation {
    pname = "iEDA-src";
    version = "2025-03-30";
    src = fetchgit {
      url = "https://gitee.com/oscc-project/iEDA";
      rev = "79bd64dec74a08cb295c9a84283bf0e47dfc5e92";
      sha256 = "sha256-uZmXVc0b37BAfZXN+mhl//SXNg3nubl+eNxZdtdae7Q=";
    };

    patches = [
      (fetchpatch {
        name = "fix-subproject-and-headers-paths.patch";
        url = "https://github.com/Emin017/iEDA/commit/a13079933763a7afdcdda7f188d630e089ae85e7.patch";
        hash = "sha256-RT+zj5YwgTiQ1pS5jxn7cjB+jZM7vjyVKZkVEVAODhs=";
      })
    ];

    dontBuild = true;
    dontFixup = true;
    installPhase = ''
      cp -r . $out
    '';

  };

  rustpkgs = callPackages ./rustpkgs.nix { inherit rootSrc; };
in
stdenv.mkDerivation {
  pname = "iEDA";
  version = "0-unstable-2025-03-30";

  src = rootSrc;

  nativeBuildInputs = [
    cmake
    ninja
    flex
    bison
    python3
    tcl
  ];

  cmakeFlags = [
    (lib.cmakeBool "CMD_BUILD" true)
    (lib.cmakeBool "SANITIZER" false)
    (lib.cmakeBool "BUILD_STATIC_LIB" false)
  ];

  preConfigure = ''
    cmakeFlags+=" -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:FILEPATH=$out/bin -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:FILEPATH=$out/lib"
  '';

  buildInputs = [
    rustpkgs.iir-rust
    rustpkgs.sdf_parse
    rustpkgs.spef-parser
    rustpkgs.vcd_parser
    rustpkgs.verilog-parser
    rustpkgs.liberty-parser
    gtest
    glog'
    gflags
    boost
    onnxruntime
    eigen
    yaml-cpp
    libunwind
    metis
    gmp
    tcl
    zlib
  ];

  postInstall = ''
    # Tests rely on hardcoded path, so they should not be included
    rm $out/bin/*test $out/bin/*Test $out/bin/test_* $out/bin/*_app
  '';

  enableParallelBuild = true;

  meta = {
    description = "Open-source EDA infracstructure and tools from Netlist to GDS for ASIC design";
    homepage = "https://gitee.com/oscc-project/iEDA";
    license = lib.licenses.mulan-psl2;
    maintainers = with lib.maintainers; [
      xinyangli
      Emin017
    ];
    mainProgram = "iEDA";
    platforms = lib.platforms.linux;
  };
}
