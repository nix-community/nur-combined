{ stdenv
, gcc11Stdenv
, onnxruntime
, lib
, fetchpatch
, fetchFromGitHub
, cudaPackages
, pythonSupport ? false
}:

let

  cutlass = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "cutlass";
    rev = "v3.0.0";
    sha256 = "sha256-YPD5Sy6SvByjIcGtgeGH80TEKg2BtqJWSg46RvnJChY=";
  };

in (onnxruntime.override {

  inherit pythonSupport;
  stdenv = gcc11Stdenv;

}).overrideAttrs (oldAttrs: rec {

  buildInputs = oldAttrs.buildInputs ++ (with cudaPackages;[
    cudatoolkit
    cudnn
    nccl
  ]);

  requiredSystemFeatures = [ "big-parallel" ];

  cmakeFlags = oldAttrs.cmakeFlags ++ [
    "-DCMAKE_CUDA_ARCHITECTURES=${with cudaPackages.cudaFlags; builtins.concatStringsSep ";" (map dropDot cudaCapabilities)}"
    "-DCMAKE_CUDA_STANDARD_REQUIRED=ON"
    "-DCMAKE_CXX_STANDARD_REQUIRED=ON"
    "-Donnxruntime_USE_CUDA=ON"
    "-Donnxruntime_CUDA_HOME=${cudaPackages.cudatoolkit}"
    "-Donnxruntime_CUDNN_HOME=${cudaPackages.cudnn}"
    "-DFETCHCONTENT_SOURCE_DIR_CUTLASS=${cutlass}"
    "-Donnxruntime_USE_NCCL=ON"
    "-DBUILD_TESTING=OFF"
    "-Donnxruntime_BUILD_UNIT_TESTS=OFF"
  ];

  patches = [
    # https://github.com/microsoft/onnxruntime/pull/17843
    (fetchpatch {
      url = "https://github.com/bverhagen/onnxruntime/commit/50d5eb3ffc19734e3f0009e800c50d626b12da14.patch";
      sha256 = "sha256-Om8qmJPts7Ly3ljBsTaSL1FoyVclh3TzEy5cZ+FTi7w=";
    })
  ];

})