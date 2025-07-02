{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  ninja,
  pkg-config,
  kdePackages,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "kiss";
  version = "0-unstable-2025-06-30";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = "kiss";
    rev = "ea8387df7d8b572b8ef18e29d7f06369413979be";
    hash = "sha256-I9Exp5YYJ+bovM5GEarqwgza81XB3UJq37Vr+k57vjs=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qtsvg
    kdePackages.kconfig
    kdePackages.ki18n
    kdePackages.kpackage
    kdePackages.libkscreen
    kdePackages.plasma-desktop
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    mainProgram = "kiss";
    description = "KDE Initial System Setup";
    homepage = "https://invent.kde.org/system/kiss";
    license = with lib.licenses; [
      bsd2
      cc0
      gpl2Plus
      gpl3Plus
      lgpl2Plus
      lgpl21Only
      lgpl21Plus
      lgpl3Only
    ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    # Requires changes in newer Plasma Desktop
    # See https://invent.kde.org/plasma/plasma-desktop/-/commit/af50724aeae3ce4429f6af4d83f2e3b52011b66d
    broken = true;
  };
}
