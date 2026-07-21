{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gettext,
  fcitx5,
  nlohmann_json,
  systemd,
  curl,
  libarchive,
  openssl,
  pipewire,
  cli11,
  onnxruntime,
  sherpa-onnx,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fcitx5-vinput";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "xifan2333";
    repo = "fcitx5-vinput";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IvmiWepQ0QKR9KJgDr/+IMsK0I14CeWRCGxxVFsYNQg=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    fcitx5
    nlohmann_json
    systemd
    curl
    libarchive
    openssl
    pipewire
    cli11
    onnxruntime
    sherpa-onnx
    qt6.qtbase
  ];

  cmakeFlags = [
    "-DVINPUT_FETCH_CLI11=OFF"
    "-DVINPUT_RUNTIME_MODE=system"
  ];

  meta = {
    description = "Offline voice input addon for Fcitx5";
    homepage = "https://github.com/xifan2333/fcitx5-vinput";
    changelog = "https://github.com/xifan2333/fcitx5-vinput/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "vinput";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
