# https://github.com/MordragT/nixos/blob/master/pkgs/oneapi/ccl.nix
{ lib
, pkgs
, fetchFromGitHub
, cmake
,
}:
let
  # https://github.com/MordragT/nixos/blob/master/pkgs/intel/dpcpp/default.nix#L5
  bintools = pkgs.callPackage ./dpcppStdenv/bintools-unwrapped.nix { };
  # https://github.com/MordragT/nixos/blob/master/pkgs/intel/dpcpp/default.nix#L16
  dpcppStdenv = pkgs.overrideCC pkgs.stdenv (pkgs.callPackage ./dpcppStdenv/wrap-dpcpp.nix {
    inherit bintools;
    inherit (pkgs) stdenv;
  });
in

# requires dpcpp compiler
dpcppStdenv.mkDerivation (finalAttrs: {
  pname = "oneapi-ccl";
  version = "2021.11.2";

  src = fetchFromGitHub {
    owner = "oneapi-src";
    repo = "oneCCL";
    rev = finalAttrs.version;
    hash = "sha256-Rpy9n9hvjYfg7+YdsjKRvJUogE4zl4V4O8NaH1IRSHo=";
  };

  nativeBuildInputs = [
    cmake
  ];

  # Tests fail on some Hydra builders, because they do not support SSE4.2.
  doCheck = false;

  meta = {
    broken = true;
    changelog = "https://github.com/oneapi-src/oneCCL/releases/tag/${finalAttrs.version}";
    description = "oneAPI Collective Communications Library (oneCCL)";
    homepage = "https://01.org/oneCCL";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mordrag ];
    platforms = lib.platforms.all;
  };
})
# Search Compute Runtime by MODULES_PATH: /build/source/cmake
# COMPUTE_BACKEND=dpcpp requested. Using DPC++ provider
# DPCPP_ROOT prefix path hint is not defiend
# Not OpenCL or L0
# -- Performing Test INTEL_SYCL_SUPPORTED
# -- Performing Test INTEL_SYCL_SUPPORTED - Success
# CMake Error at /nix/store/17r6ld906midfv8y7997fd56s7a87vrg-cmake-3.28.3/share/cmake-3.28/Modules/FindPackageHandleStandardArgs.cmake:230 (message):
#   Could NOT find IntelSYCL_level_zero (missing: INTEL_SYCL_LIBRARIES
#   INTEL_SYCL_INCLUDE_DIRS)
# Call Stack (most recent call first):
#   /nix/store/17r6ld906midfv8y7997fd56s7a87vrg-cmake-3.28.3/share/cmake-3.28/Modules/FindPackageHandleStandardArgs.cmake:600 (_FPHSA_FAILURE_MESSAGE)
#   cmake/FindIntelSYCL_level_zero.cmake:62 (find_package_handle_standard_args)
#   cmake/helpers.cmake:201 (find_package)
#   cmake/helpers.cmake:256 (activate_compute_backend)
#   CMakeLists.txt:204 (set_compute_backend)

