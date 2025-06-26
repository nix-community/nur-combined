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
  rootSrc = stdenv.mkDerivation {
    pname = "iEDA-src";
    version = "0-unstable-2025-06-05";
    src = fetchgit {
      url = "https://gitee.com/oscc-project/iEDA";
      rev = "7afa129e1dd2274e0c800ad7a6daa3219d06bf59";
      sha256 = "sha256-rP8hs4+5DfGLIOhphm3DsyOyOm/tP+/sd8Q6XS0FEaA=";
      fetchSubmodules = true;
    };

    postPatch = ''
      # Comment out the iCTS test cases that will fail due to some linking issues on aarch64-linux
      sed -i '17,28s/^/# /' src/operation/iCTS/test/CMakeLists.txt
    '';

    patches = [
      # This patch is to fix the build error caused by the missing of the header file,
      # and remove some libs or path that they hard-coded in the source code.
      # Should be removed after we upstream these changes.
      (fetchpatch {
        url = "https://github.com/Emin017/iEDA/commit/e899b432776010048b558a939ad9ba17452cb44f.patch";
        hash = "sha256-fLKsb/dgbT1mFCWEldFwhyrA1HSkKGMAbAs/IxV9pwM=";
      })
      # This patch is to fix the compile error on the newer version of gcc/g++
      # which is caused by some incorrect declarations and usages of the Boost library.
      # Should be removed after we upstream these changes.
      (fetchpatch {
        url = "https://github.com/Emin017/iEDA/commit/f5464cc40a2c671c5d405f16b509e2fa8d54f7f1.patch";
        hash = "sha256-uVMV/CjkX9oLexHJbQvnEDOET/ZqsEPreI6EQb3Z79s=";
      })
      # This patch is to fix the glog compatibility issue with the 0.7.1 version glog
      ./glog.patch
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
  version = "0-unstable-2025-06-05";

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
    glog
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
