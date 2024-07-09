# https://github.com/MordragT/nixos/blob/master/pkgs/oneapi/mkl.nix
{ lib
, pkgs
, fetchFromGitHub
, cmake
, level-zero
, blas
, lapack
, blas-reference
, lapack-reference
, ...
}:
let
  # https://github.com/MordragT/nixos/blob/master/pkgs/intel/dpcpp/default.nix#L5
  bintools = pkgs.callPackage ./dpcppStdenv/bintools-unwrapped.nix { };
  # https://github.com/MordragT/nixos/blob/master/pkgs/intel/dpcpp/default.nix#L16
  dpcppStdenv = pkgs.overrideCC pkgs.stdenv (pkgs.callPackage ./dpcppStdenv/wrap-dpcpp.nix {
    inherit bintools;
    inherit (pkgs) stdenv;
  });
  # https://github.com/MordragT/nixos/blob/master/pkgs/intel/mkl.nix
  intel-mkl = pkgs.callPackage ./intel-mkl { };
  # https://github.com/MordragT/nixos/blob/master/pkgs/intel/tbb.nix
  intel-tbb = pkgs.callPackage ./intel-tbb { };
in
# let
  #   blas' = blas.override {
  #     blasProvider = intel-mkl;
  #     isILP64 = true;
  #   };
  #   lapack' = lapack.override {
  #     lapackProvider = intel-mkl;
  #     isILP64 = true;
  #   };
  # in
  # requires dpcpp compiler
dpcppStdenv.mkDerivation (finalAttrs: {
  pname = "oneapi-mkl";
  # version = "0.3";
  version = "develop";

  src = fetchFromGitHub {
    owner = "oneapi-src";
    repo = "oneMKL";
    # rev = "v${finalAttrs.version}";
    # hash = "sha256-RQnAsjnzBZRCPbXtDDWEYHlRjY6YAP5mEwr/7CpcTYw=";
    rev = "3339418fa1318377c65815e6f85aced9efa46e9e";
    hash = "sha256-hiZV3jp3Jz35CHy/O/y3+ZFDDRcpmgxMxRROxhrbFQ8=";
  };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DBUILD_FUNCTIONAL_TESTS=OFF"
    "-DREF_BLAS_ROOT=${blas-reference}"
    "-DREF_LAPACK_ROOT=${lapack-reference}"
    "-DMKL_ROOT=${intel-mkl}"
    # "-DBUILD_SHARED_LIBS=OFF"
  ];

  buildInputs = [
    intel-mkl
    level-zero
    intel-tbb
    blas.dev
    lapack.dev
  ];

  # Tests fail on some Hydra builders, because they do not support SSE4.2.
  doCheck = false;

  meta = {
    broken = true;
    changelog = "https://github.com/oneapi-src/oneMKL/releases/tag/v${finalAttrs.version}";
    description = "oneAPI Math Kernel Library (oneMKL) Interfaces";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mordrag ];
    platforms = lib.platforms.all;
  };
})
