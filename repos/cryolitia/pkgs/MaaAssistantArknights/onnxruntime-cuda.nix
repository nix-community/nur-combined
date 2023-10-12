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

# assert stdenv.hostPlatform.system == "x86_64-linux";

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

  meta = with lib; {
    description = "Cross-platform, high performance scoring engine for ML models";
    longDescription = ''
      ONNX Runtime is a performance-focused complete scoring engine
      for Open Neural Network Exchange (ONNX) models, with an open
      extensible architecture to continually address the latest developments
      in AI and Deep Learning. ONNX Runtime stays up to date with the ONNX
      standard with complete implementation of all ONNX operators, and
      supports all ONNX releases (1.2+) with both future and backwards
      compatibility.
    '';
    homepage = "https://github.com/microsoft/onnxruntime";
    changelog = "https://github.com/microsoft/onnxruntime/releases/tag/v${version}";
    platforms = [ "x86_64-linux" ];
    broken = stdenv.hostPlatform.system != "x86_64-linux";
    license = licenses.mit;
  };

}
