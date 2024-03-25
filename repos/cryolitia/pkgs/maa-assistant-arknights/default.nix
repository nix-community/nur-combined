{ lib
, config
, callPackage
, stdenv
, fetchFromGitHub
, asio
, cmake
, eigen
, libcpr
, onnxruntime
, opencv
, isBeta ? false
, cudaSupport ? config.cudaSupport
, cudaPackages ? { }
}:

let
  fastdeploy = callPackage ./fastdeploy-ppocr.nix { };
  sources = lib.importJSON ./pin.json;
in
stdenv.mkDerivation (finalAttr: {
  pname = "maa-assistant-arknights" + lib.optionalString isBeta "-beta";
  version = if isBeta then sources.beta.version else sources.stable.version;

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "MaaAssistantArknights";
    rev = "v${finalAttr.version}";
    hash = if isBeta then sources.beta.hash else sources.stable.hash;
  };

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=maa-assistant-arknights
  postPatch = ''
    sed -e 's/RUNTIME\sDESTINATION\s\./ /g' \
        -e 's/LIBRARY\sDESTINATION\s\./ /g' \
        -e 's/PUBLIC_HEADER\sDESTINATION\s\./ /g' -i CMakeLists.txt
    sed -e 's/find_package(asio /# find_package(asio /g' \
        -e 's/asio::asio/ /g' -i CMakeLists.txt

    shopt -s globstar nullglob
    sed -i 's/onnxruntime\/core\/session\///g' src/MaaCore/**/{*.h,*.cpp,*.hpp,*.cc}

    sed -i 's/ONNXRuntime/onnxruntime/g' CMakeLists.txt

    cp -v ${fastdeploy.cmake}/Findonnxruntime.cmake cmake/
  '';

  nativeBuildInputs = [
    asio
    cmake
    fastdeploy.cmake
  ] ++ lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    fastdeploy
    libcpr
    onnxruntime
    opencv
  ] ++ lib.optionals cudaSupport (with cudaPackages; [
    cuda_cccl # cub/cub.cuh
    libcublas # cublas_v2.h
    libcurand # curand.h
    libcusparse # cusparse.h
    libcufft # cufft.h
    cudnn # cudnn.h
    cuda_cudart
  ]);

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=None"
    "-DUSE_MAADEPS=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DINSTALL_RESOURCE=ON"
    "-DINSTALL_PYTHON=ON"
    "-DMAA_VERSION=v${finalAttr.version}"
  ];

  passthru.updateScript = ./update.sh;

  postInstall = ''
    mkdir -p $out/share/${finalAttr.pname}
    mv $out/{Python,resource} $out/share/${finalAttr.pname}
  '';

  meta = with lib; {
    description = "An Arknights assistant";
    homepage = "https://github.com/MaaAssistantArknights/MaaAssistantArknights";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ Cryolitia ];
    platforms = platforms.linux;
  };
})
