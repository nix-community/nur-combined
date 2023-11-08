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
cudaPackages.backendStdenv.mkDerivation rec {

  pname = "fastdeploy_ppocr";
  version = "20231009-unstable";

  src = fetchFromGitHub {
    owner = "Cryolitia";
    repo = "FastDeploy";
    # follows https://github.com/MaaAssistantArknights/MaaDeps/blob/master/vcpkg-overlay/ports/maa-fastdeploy/portfile.cmake#L4
    rev = "cf34b7e2a7cda95275d81132c580fcdf00a521b8";
    sha256 = "sha256-10fBWijZwWnDVr+rUZk6ZYpsrFZk9DafuAC1IUmKCXg=";
  };

  nativeBuildInputs = [
    cmake
    eigen
  ] ++ lib.optionals cudaSupport cuda.cuda-native-redist;

  buildInputs = [
    opencv
    onnxruntime
  ] ++ lib.optionals cudaSupport cuda.cuda-common-redist;

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=None"
    "-DBUILD_SHARED_LIBS=ON"
    "-DPRINT_LOG=ON"
  ] ++ lib.optionals cudaSupport [
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
