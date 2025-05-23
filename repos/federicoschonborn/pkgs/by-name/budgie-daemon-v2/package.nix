{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  kdePackages,
  wayland,
  nix-update-script,
}:

stdenv.mkDerivation (_: {
  pname = "budgie-daemon-v2";
  version = "0-unstable-2025-03-19";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "budgie-daemon-v2";
    rev = "0e5283f28184cbd33175571e44e34723879aebd3";
    hash = "sha256-IZ+hbv7bZC4fqrD6hPBiJKfi59+PmxPxphh6MquMgls=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    kdePackages.extra-cmake-modules
    kdePackages.qtbase
    kdePackages.qtwayland
    kdePackages.kwayland
    wayland
  ];

  strictDeps = true;

  cmakeFlags = [
    "-DQtWaylandScanner_EXECUTABLE=${kdePackages.qtwayland}/libexec/qtwaylandscanner"
  ];

  postPatch = ''
    substituteInPlace src/CMakeLists.txt --replace-fail "/etc/xdg/labwc" "$out/etc/xdg/labwc"
  '';

  dontWrapQtApps = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    mainProgram = "org.buddiesofbudgie.BudgieDaemonV2";
    description = "V2 daemon for Budgie Desktop";
    homepage = "https://github.com/BuddiesOfBudgie/budgie-daemon-v2";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
