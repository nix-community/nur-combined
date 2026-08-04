{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  ninja,
  pkg-config,
  wayland,
  wayland-protocols,
  kdePackages,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "plasma-keyboard";
  version = "0-unstable-2025-06-03";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "plasma-keyboard";
    rev = "93cfff2b712a74c6ee678fd2e033d2ca9d4a6a0d";
    hash = "sha256-Xdc9zrrvOGhkJiagpg7eZIBapknjvcXya+dB13tbKuE=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    wayland
    wayland-protocols
    kdePackages.kcoreaddons
    kdePackages.ki18n
    kdePackages.qtbase
    kdePackages.qtvirtualkeyboard
    kdePackages.qtwayland
  ];

  cmakeFlags = [
    "-DQtWaylandScanner_EXECUTABLE=${kdePackages.qtwayland}/libexec/qtwaylandscanner"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    mainProgram = "plasma-keyboard";
    description = "Virtual Keyboard for Qt based desktops";
    homepage = "https://invent.kde.org/plasma/plasma-keyboard";
    license = with lib.licenses; [
      gpl2Only
      gpl3Only
      lgpl21Only
      lgpl3Only
      mit
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
