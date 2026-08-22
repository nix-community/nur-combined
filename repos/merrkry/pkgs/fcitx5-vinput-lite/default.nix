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
}:

stdenv.mkDerivation {
  __structuredAttrs = true;

  pname = "fcitx5-vinput-lite";
  version = "2.3.8";

  src = fetchFromGitHub {
    owner = "xifan2333";
    repo = "fcitx5-vinput";
    rev = "4afe1fdb6ad141821d0aa0e974ab55454d4ffcdd";
    hash = "sha256-Pbg+M5lAlr33JYOw5fBLwsHulR7UmUt6BW79jaq1VUQ=";
  };

  patches = [ ./optional-local-asr.patch ];

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
    "-DVINPUT_ENABLE_LOCAL_ASR=OFF"
    "-DVINPUT_RUNTIME_MODE=system"
    "-DVINPUT_FETCH_CLI11=OFF"
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

  meta = {
    description = "Voice input addon for Fcitx5, built without local ASR";
    homepage = "https://github.com/xifan2333/fcitx5-vinput";
    license = lib.licenses.gpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "vinput";
  };
}
