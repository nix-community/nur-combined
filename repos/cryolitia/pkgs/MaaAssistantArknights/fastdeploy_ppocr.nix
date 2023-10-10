# imitate https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=maa-assistant-arknights

{ stdenv
, pkgs
, lib
, fetchFromGitHub
, cmake
, opencv
, eigen
, cudaPackages
}:

let

  onnxruntime = pkgs.callPackage ./onnxruntime-cuda.nix { };

in stdenv.mkDerivation rec {

  pname = "fastdeploy_ppocr";
  version = "20231009-unstable";

  src = fetchFromGitHub {
    owner = "Cryolitia";
    repo = "FastDeploy";
    rev = "cb09da245b416cd2b101548b1aa3c3bddf5b12a0";
    sha256 = "sha256-6WRW8ZqOtnM3Y4xw2PeV9OXuVcfF5+blYNuV6hegCik=";
  };

  nativeBuildInputs = [
    cmake
    eigen
  ];

  buildInputs = [
    opencv
    onnxruntime
    cudaPackages.cudatoolkit
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=None"
    "-DBUILD_SHARED_LIBS=ON"
    "-DWITH_GPU=ON"
    "-DPRINT_LOG=ON"
    "-DCUDA_DIRECTORY=${cudaPackages.cudatoolkit}"
  ];

}
