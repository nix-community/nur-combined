{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, cudaPackages
, openmpi
, nsync
, abseil-cpp
, fetchzip
}:

let

  ver = "1.15.1";

  src2 = fetchzip {
    url = "https://github.com/microsoft/onnxruntime/archive/refs/tags/v${ver}.zip";
    sha256 = "sha256-KZWIAYrwSznIKOvh1rcYJQQ2Q6a/DuWmt4NxM2ztxkM";
  };

in stdenv.mkDerivation rec {

  pname = "onnxruntime-cuda";
  version = ver;

  src = fetchurl {
    url = "https://github.com/microsoft/onnxruntime/releases/download/v${version}/onnxruntime-linux-x64-gpu-${version}.tgz";
    sha256 = "sha256-6riROTAl7dWBjRqiakKGDlc5/MSePKP4dhEOyHNv5/E=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    cudaPackages.nccl
    openmpi
    nsync
    abseil-cpp
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

}
