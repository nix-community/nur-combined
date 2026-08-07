{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  cmake,
  pkg-config,
  kdePackages,
  openssl,
  libpulseaudio,
  qt6,
  installShellFiles,
  copyDesktopItems,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "librepods";
  version = "1.0.0-rc1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "librepods-org";
    repo = "librepods";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q1JX83ewLgyscgcTbh6Mb21ZBCMxrOZFv1jhqNkwMUI=";
  };

  sourceRoot = "source/linux";

  nativeBuildInputs = [
    cmake
    pkg-config

    kdePackages.qtbase
    kdePackages.qtconnectivity
    kdePackages.qtdeclarative
    kdePackages.qtmultimedia
    kdePackages.qttools

    openssl
    libpulseaudio

    qt6.wrapQtAppsHook

    installShellFiles
    copyDesktopItems
  ];

  # linux/assets/me.kavishdevar.librepods.desktop
  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "LibrePods";
      comment = finalAttrs.meta.description;
      icon = "librepods";
      exec = finalAttrs.meta.mainProgram;
      categories = [
        "Audio"
        "AudioVideo"
        "Utility"
        "Qt"
      ];
      terminal = false;
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AirPods liberated from Apple's ecosystem";
    homepage = "https://github.com/librepods-org/librepods";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "librepods";
    platforms = lib.platforms.all;
  };
})
