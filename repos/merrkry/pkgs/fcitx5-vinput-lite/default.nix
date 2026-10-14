{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  fcitx5,
  makeBinaryWrapper,
  qt6,
  systemdLibs,
  curl,
  libarchive,
  openssl,
  pipewire,
  cli11,
  nlohmann_json,
  python3,
  libopus,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "fcitx5-vinput-lite";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "xifan2333";
    repo = "fcitx5-vinput";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Tl/wjOVBHgBxzP8xpCMwJ5ARvcLLglurxjWhdLEsVk0=";
  };

  strictDeps = true;
  nativeBuildInputs = [
    cmake
    pkg-config
    gettext
    fcitx5
    makeBinaryWrapper
    qt6.wrapQtAppsHook
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
  ];

  cmakeFlags = [
    # Keep sherpa-onnx and ONNX Runtime out of the build dependencies.
    "-DVINPUT_ENABLE_LOCAL_ASR=OFF"
    "-DVINPUT_RUNTIME_MODE=system"
    "-DVINPUT_FETCH_CLI11=OFF"
    "-DVINPUT_FETCH_NLOHMANN_JSON=OFF"
    "-DBUILD_TESTING=ON"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  doCheck = true;

  postInstall = ''
    for program in "$out"/bin/*; do
      wrapProgram "$program" \
        --prefix PATH : ${lib.makeBinPath [ python3 ]} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libopus ]}
    done
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Voice input for Fcitx5 with cloud ASR and LLM rewriting";
    homepage = "https://github.com/xifan2333/fcitx5-vinput";
    changelog = "https://github.com/xifan2333/fcitx5-vinput/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ merrkry ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "vinput";
  };
})
