{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, gettext
, fcitx5
, makeBinaryWrapper
, qt6
, autoPatchelfHook
, systemdLibs
, curl
, libarchive
, openssl
, pipewire
, cli11
, nlohmann_json
, clang
, mold
, python3
, libopus
, withKeyRepeatFix ? true
}:

stdenv.mkDerivation {
  pname = "fcitx5-vinput-lite";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "xifan2333";
    repo = "fcitx5-vinput";
    rev = "ac545c6c5ec1105f0c4ec8b54b21dd3a79a544a4";
    hash = "sha256-jZxyxDEUYuGDh7c27yiGYn6BW0KzfgwX+HW9nXmvCoo=";
  };

  patches = lib.optional withKeyRepeatFix ./vinput-key-repeat.patch;
  postPatch = lib.optionalString withKeyRepeatFix ''
    cp ${./test-vinput-key-repeat.cpp} tests/test_vinput_key_repeat.cpp
    cat ${./vinput-key-repeat.cmake} >> tests/CMakeLists.txt
  '';
  nativeBuildInputs = [
    cmake
    pkg-config
    gettext
    fcitx5
    makeBinaryWrapper
    qt6.wrapQtAppsHook
    autoPatchelfHook
  ];
  buildInputs = [
    fcitx5
    systemdLibs
    curl
    libarchive
    openssl
    pipewire
    qt6.qtbase
    cli11
    nlohmann_json
    clang
    mold
  ];
  cmakeFlags = [
    "-DVINPUT_ENABLE_LOCAL_ASR=OFF"
    "-DVINPUT_FETCH_CLI11=OFF"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_C_COMPILER=clang"
    "-DCMAKE_CXX_COMPILER=clang++"
    "-DCMAKE_LINKER=mold"
    "-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=mold"
    "-DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=mold"
  ] ++ lib.optional withKeyRepeatFix "-DBUILD_TESTING=ON";

  doCheck = withKeyRepeatFix;
  checkPhase = ''
    runHook preCheck
    cmake --build . --target test_vinput_key_repeat -j$NIX_BUILD_CORES
    ctest --output-on-failure -R '^vinput_key_repeat$'
    runHook postCheck
  '';
  postInstall = ''
    for program in "$out"/bin/*; do
      wrapProgram "$program" \
        --prefix PATH : ${lib.makeBinPath [ python3 ]} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libopus ]}
    done
  '';

  meta = {
    description = "Voice input addon for Fcitx5 without local ASR";
    homepage = "https://github.com/xifan2333/fcitx5-vinput";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "vinput";
  };
}
