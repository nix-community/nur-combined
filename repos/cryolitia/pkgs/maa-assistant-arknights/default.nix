{ lib
, callPackage
, stdenv
, fetchFromGitHub
, asio
, cmake
, eigen
, libcpr
, onnxruntime
, opencv
}:

let
  fastdeploy = callPackage ./fastdeploy-ppocr.nix { };
in
stdenv.mkDerivation (finalAttr: {
  pname = "maa-assistant-arknights";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "MaaAssistantArknights";
    rev = "v${finalAttr.version}";
    hash = "sha256-vxGJHm1StQNN+0IVlGMqKVKW56LH6KUC94utDn7FcNo=";
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
  ];

  buildInputs = [
    fastdeploy
    libcpr
    onnxruntime
    opencv
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=None"
    "-DUSE_MAADEPS=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DINSTALL_RESOURCE=ON"
    "-DINSTALL_PYTHON=ON"
    "-DMAA_VERSION=v${finalAttr.version}"
  ];

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
