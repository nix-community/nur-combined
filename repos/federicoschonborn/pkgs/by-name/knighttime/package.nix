{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  ninja,
  kdePackages,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "knighttime";
  version = "0-unstable-2025-06-30";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "knighttime";
    rev = "137d8cc04b66604aa46e17e1a4524f6bd4c75c53";
    hash = "sha256-1rd5Pary48MjuKA33SciWdU5PeARZTb9CR1c/DvoDGU=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    kdePackages.extra-cmake-modules
  ];

  buildInputs = [
    kdePackages.kconfig
    kdePackages.kcoreaddons
    kdePackages.kdbusaddons
    kdePackages.kholidays
    kdePackages.ki18n
    kdePackages.qtbase
    kdePackages.qtpositioning
  ];

  postPatch = ''
    substituteInPlace src/CMakeLists.txt --replace-fail "ecm_generate_qdoc" "# ecm_generate_qdoc"
  '';

  dontWrapQtApps = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Helpers for scheduling the dark-light cycle";
    homepage = "https://invent.kde.org/plasma/knighttime";
    licenses = with lib.licenses; [
      bsd3
      cc0
      gpl2Only
      gpl3Only
      lgpl21Only
      lgpl3Only
      mit
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    # 6.15.0 introduced KHolidays/SunEvents
    broken = lib.versionOlder kdePackages.kholidays.version "6.15.0";
  };
}
