{
  lib,
  stdenv,
  fetchFromGitLab,
  kdePackages,
  cmake,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "plasma-login";
  version = "0-unstable-2025-04-01";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "davidedmundson";
    repo = "plasma-login";
    rev = "747fab863bf5c9c6b7fbf2e5374613f7db88637d";
    hash = "sha256-ItrIONr9JLw4HZtlbS2Ibziz4vQg7UxYyysqvRbeD4E=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.kauth
    kdePackages.kcmutils
    kdePackages.kconfig
    kdePackages.kdbusaddons
    kdePackages.ki18n
    kdePackages.kio
    kdePackages.kpackage
    kdePackages.kwindowsystem
    kdePackages.layer-shell-qt
    kdePackages.libplasma
    kdePackages.plasma-workspace
  ];

  strictDeps = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    mainProgram = "plasma-login";
    description = "Plasma Login provides the frontend for Plasma's login experience";
    homepage = "https://invent.kde.org/davidedmundson/plasma-login";
    license = lib.licenses.unfree;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
