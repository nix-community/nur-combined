{
  lib,
  stdenv,
  fetchFromGitLab,
  kdePackages,
  cmake,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kiview";
  version = "1.1";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "danagost";
    repo = "Kiview";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MlXrCKEMSOoTq6Lkc//ZE9r2b2Img8lYBRjvlImqIAI=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
    ninja
  ];

  buildInputs = [
    kdePackages.kcoreaddons
    kdePackages.ki18n
    kdePackages.kirigami
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qtwebengine
  ] ++ lib.optional stdenv.hostPlatform.isLinux kdePackages.qtwayland;

  strictDeps = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "kiview";
    description = "Quick file preview for Dolphin";
    homepage = "https://invent.kde.org/danagost/Kiview";
    changelog = "https://invent.kde.org/danagost/Kiview/-/tags/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
