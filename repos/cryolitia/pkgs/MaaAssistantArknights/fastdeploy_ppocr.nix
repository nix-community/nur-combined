# imitate https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=maa-assistant-arknights

{ stdenv
, config
, pkgs
, lib
, fetchFromGitHub
, cmake
, opencv
, eigen
, cudaSupport ? config.cudaSupport
, cudaPackages ? { }
, symlinkJoin
, onnxruntime-cuda ? pkgs.callPackage ./onnxruntime-cuda.nix { }
}:

let

  onnxruntime = if cudaSupport then onnxruntime-cuda else pkgs.onnxruntime;

  cuda = import ../common/cuda.nix { inherit cudaPackages; inherit symlinkJoin; };

in
stdenv.mkDerivation rec {

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
  ] ++ lib.optionals cudaSupport [
    cuda.cuda-native-redist
  ];

  buildInputs = [
    opencv
    onnxruntime
  ] ++ lib.optionals cudaSupport [
    cuda.cuda-redist
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=None"
    "-DBUILD_SHARED_LIBS=ON"
    "-DPRINT_LOG=ON"
  ] ++ lib.optional cudaSupport [
    "-DWITH_GPU=ON"
    "-DCUDA_DIRECTORY=${cuda.cuda-redist}"
  ];

  meta = with lib; {
    description = "MAAAssistantArknights stripped-down version of FastDeploy";
    homepage = "https://github.com/MaaAssistantArknights/FastDeploy/";
    platforms = platforms.linux ++ platforms.darwin;
    license = licenses.apsl20;
    broken = cudaSupport && stdenv.hostPlatform.system != "x86_64-linux";
  };

}
