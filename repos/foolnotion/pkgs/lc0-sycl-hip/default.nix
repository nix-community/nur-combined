{ pkgs, rocmGpuTarget ? "gfx1201" }:
let
  inherit (pkgs) lib;

  intelLlvmHip = pkgs.intel-llvm.overrideScope (final: prev: {
    unwrapped = prev.unwrapped.override {
      rocmSupport = true;
      rocmPackages = pkgs.rocmPackages;
      rocmGpuTargets = rocmGpuTarget;
      cudaSupport = false;
      levelZeroSupport = false;
      nativeCpuSupport = false;
    };
  });
in
(pkgs.lc0.override {
  stdenv = intelLlvmHip.stdenv;
}).overrideAttrs (old: {
  version = "unstable-2026-05-06";
  src = pkgs.fetchFromGitHub {
    owner = "LeelaChessZero";
    repo = "lc0";
    rev = "d8ce48258c39d331c119f8c8729374ceb3df8409";
    hash = "sha256-bVcjO6T4CpLpGm7LnRoW5hhojgcJOe1d8pl3sKG6Gzc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.makeWrapper ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "if eigen_dep.found() and cc.has_header('Eigen/Core', dependencies: eigen_dep)" "if eigen_dep.found()"
  '';

  buildInputs = old.buildInputs ++ [
    intelLlvmHip
    pkgs.rocmPackages.clr
    pkgs.rocmPackages.hipblas
    pkgs.rocmPackages.rocblas
  ];

  doCheck = false;

  mesonFlags = old.mesonFlags ++ [
    "-Db_lto=false"
    "-Dgtest=false"
    "-Dsycl=amd"
    "-Damd_gfx=${rocmGpuTarget}"
    "-Dhip_libdirs=['${pkgs.rocmPackages.clr}/lib','${pkgs.rocmPackages.hipblas}/lib','${pkgs.rocmPackages.rocblas}/lib']"
    "-Dhip_include=['${pkgs.rocmPackages.clr}/include','${pkgs.rocmPackages.hipblas}/include']"
  ];

  preConfigure = (old.preConfigure or "") + ''
    export AR=${intelLlvmHip}/bin/llvm-ar
  '';

  postFixup = (old.postFixup or "") + ''
    wrapProgram $out/bin/lc0 \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        intelLlvmHip
        pkgs.rocmPackages.clr
        pkgs.rocmPackages.hipblas
        pkgs.rocmPackages.rocblas
      ]} \
      --set UR_ADAPTERS_FORCE_LOAD ${intelLlvmHip}/lib/libur_adapter_hip.so.0 \
      --run 'export ONEAPI_DEVICE_SELECTOR=hip:*'
  '';

  passthru = (old.passthru or { }) // {
    inherit intelLlvmHip rocmGpuTarget;
  };
})
