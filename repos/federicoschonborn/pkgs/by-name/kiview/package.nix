{
  lib,
  stdenv,
  fetchFromGitLab,
  kdePackages,
  cmake,
  ninja,
  qt6,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kiview";
  version = "1.1";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "danagost";
    repo = "Kiview";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-MlXrCKEMSOoTq6Lkc//ZE9r2b2Img8lYBRjvlImqIAI=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.kcoreaddons
    kdePackages.ki18n
    kdePackages.kirigami
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwebengine
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "kiview";
    description = "Quick file preview for Dolphin";
    homepage = "https://invent.kde.org/danagost/Kiview";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
