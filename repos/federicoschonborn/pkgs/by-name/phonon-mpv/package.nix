{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  kdePackages,
  mpv,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "phonon-mpv";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "OpenProgger";
    repo = "phonon-mpv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IBCCQPI1Vrgj1hXlB3wxAIXjyLoKuNVc18P/X3axioE=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.wrapQtAppsHook
    ninja
    pkg-config
  ];

  buildInputs = [
    kdePackages.phonon
    kdePackages.qtbase
    mpv
  ];

  strictDeps = true;

  cmakeFlags = [
    (lib.cmakeBool "PHONON_BUILD_QT5" false)
    (lib.cmakeBool "PHONON_BUILD_QT6" true)
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "unstable"
    ];
  };

  meta = {
    description = "Phonon Backend using MPV Player";
    homepage = "https://github.com/OpenProgger/phonon-mpv";
    changelog = "https://github.com/OpenProgger/phonon-mpv/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
