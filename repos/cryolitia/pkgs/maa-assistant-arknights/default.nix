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
, isBeta ? false
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
    rev = "${finalAttr.version}";
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
    "-DMAA_VERSION=${finalAttr.version}"
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
