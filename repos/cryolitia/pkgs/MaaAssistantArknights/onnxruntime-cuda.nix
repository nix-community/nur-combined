{ stdenv
, onnxruntime
, lib
, fetchpatch
, cudaPackages
, pythonSupport ? false
}:

let

  _CUDA_ARCHITECTURES="52-real;53-real;60-real;61-real;62-real;70-real;72-real;75-real;80-real;86-real;87-real;89-real;90-real;90-virtual";

in (onnxruntime.override {

  inherit pythonSupport;

}).overrideAttrs (oldAttrs: rec {

  buildInputs = oldAttrs.buildInputs ++ (with cudaPackages;[
    cudatoolkit
    cudnn
    nccl
  ]);

  cmakeFlags = oldAttrs.cmakeFlags ++ [
    "-DCMAKE_CUDA_ARCHITECTURES=${_CUDA_ARCHITECTURES}"
    "-DCMAKE_CUDA_STANDARD_REQUIRED=ON"
    "-DCMAKE_CXX_STANDARD_REQUIRED=ON"
    "-Donnxruntime_USE_CUDA=ON"
    "-Donnxruntime_CUDA_HOME=${cudaPackages.cudatoolkit}"
    "-Donnxruntime_CUDNN_HOME=${cudaPackages.cudnn}"
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