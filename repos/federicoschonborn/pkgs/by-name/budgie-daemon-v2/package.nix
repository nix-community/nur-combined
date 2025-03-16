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
  version = "0-unstable-2025-03-04";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "budgie-daemon-v2";
    rev = "f6c2c7f4a028a4677419e807667ce75d2d13033b";
    hash = "sha256-U2UBQSm7ZfcdhvSrPn9SDy0QpSPIUTu1S5tplLPRdPY=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    kdePackages.extra-cmake-modules
    kdePackages.qtbase
    kdePackages.qtwayland
    wayland
  ];

  cmakeFlags = [
    "-DQtWaylandScanner_EXECUTABLE=${kdePackages.qtwayland}/libexec/qtwaylandscanner"
  ];

  postPatch = ''
    substituteInPlace src/CMakeLists.txt --replace-fail "/etc/xdg/labwc" "$out/etc/xdg/labwc"
  '';

  dontWrapQtApps = true;

  strictDeps = true;

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
