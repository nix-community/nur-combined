{
  lib,
  fetchFromGitHub,
  stdenv,
  cmake,
  ninja,
  fetchzip,
  which,
  boost,
  libpng,
  opencl-headers,
  ocl-icd,
  level-zero,
  gtest,
  libva,
  runCommand,
}:
let
  yuv_samples = fetchzip {
    name = "yuv_samples";
    extension = "tgz";
    url = "https://software.intel.com/file/604709/download";
    hash = "sha256-7b41WJFbEyG6keOabHO4U7WYB0lzihVyGiZ83gFnDLM=";
  };

  mediadata = runCommand "mediadata" { } ''
    mkdir -p $out/yuv
    cp -R ${yuv_samples}/* $out/yuv
  '';
in
stdenv.mkDerivation {
  pname = "intel-compute-samples";
  version = "0.3.0-unstable-2025-09-10";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "compute-samples";
    rev = "b18e178ba784e8eff20c2a57314a6df4d9d2f7c1";
    hash = "sha256-3KVXrPZgqCJa4w1teuTcwTQkS21SGDMGghzjVgcELa8=";
  };

  passthru = { inherit mediadata; };

  nativeBuildInputs = [
    cmake
    ninja
    gtest
  ];

  buildInputs = [
    boost
    libpng
    opencl-headers
    ocl-icd
    level-zero
    libva
  ];

  cmakeFlags = [
    "-DL0_ROOT=${level-zero}"
    "-DMEDIADATA_ROOT=${mediadata}"
  ];

  patchPhase = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'include(import_boost)' 'find_package(Boost REQUIRED COMPONENTS log program_options timer chrono)' \
      --replace-fail 'include(import_opencl)' 'find_package(OpenCL REQUIRED)' \
      --replace-fail 'include(import_gtest)' $'find_package(GTest REQUIRED)\nadd_library(GMock::GMock ALIAS GTest::gmock)'

    substituteInPlace compute_samples/core/utils/include/utils/utils.hpp \
      --replace-fail '#include <cstring>' $'#include <cstring>\n#include <cstdint>'
  '';

  meta = {
    description = "Sample applications for Intel Compute APIs (OpenCL, Level Zero)";
    homepage = "https://github.com/intel/compute-samples";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.skyesoss ];
  };
}
