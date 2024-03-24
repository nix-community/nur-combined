{ stdenvNoCC
, pkgs
, lib
, fetchurl
, autoPatchelfHook
, openmpi
, nsync
, abseil-cpp
, fetchzip
, symlinkJoin
, cudaPackages_11
}:

let

  ver = "1.15.1";

  src2 = fetchzip {
    url = "https://github.com/microsoft/onnxruntime/archive/refs/tags/v${ver}.zip";
    sha256 = "sha256-KZWIAYrwSznIKOvh1rcYJQQ2Q6a/DuWmt4NxM2ztxkM=";
  };

in stdenvNoCC.mkDerivation rec {

  pname = "onnxruntime-cuda-bin";
  version = ver;

  src = fetchurl {
    url = "https://github.com/microsoft/onnxruntime/releases/download/v${version}/onnxruntime-linux-x64-gpu-${version}.tgz";
    sha256 = "sha256-6riROTAl7dWBjRqiakKGDlc5/MSePKP4dhEOyHNv5/E=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = with cudaPackages_11; [
    openmpi
    nsync
    abseil-cpp
    cuda_cccl # cub/cub.cuh
    libcublas # cublas_v2.h
    libcurand # curand.h
    libcusparse # cusparse.h
    libcufft # cufft.h
    cudnn # cudnn.h
    cuda_cudart
  ];

  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -pv $out
    cp -rv ./* $out
    rm -v $out/lib/libonnxruntime_providers_tensorrt.so

    cp -rv ${src2}/include/* $out/include/
    
    runHook postInstall
  '';

  meta = pkgs.onnxruntime.meta // (with lib; {
    platforms = [ "x86_64-linux" ];
    broken = stdenvNoCC.hostPlatform.system != "x86_64-linux";
  });

}
