{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
  kdePackages,
  aeroshell-libplasma,
}:

stdenv.mkDerivation rec {
  pname = "aeroshell-workspace";
  version = "0";

  src = fetchFromGitHub {
    owner = "aeroshell-desktop";
    repo = pname;
    rev = "c4119706f0c753477942f4b0ac7dcb5db3446f1d";
    hash = "sha256-84PsJDoob0pdXJvNiXAMJlzhlz3xcRYyiQiD2r0K5n4=";
  };

  dontWrapQtApps = true;

  buildInputs = [
    aeroshell-libplasma
  ]
  ++ (with kdePackages; [
    qtbase
    qtdeclarative
    sddm
    kconfig
    kcmutils
    libksysguard
    plasma-workspace
    kjobwidgets
    plasma-activities-stats
    ki18n
    kcoreaddons
    kservice
    kio
  ]);

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
  ];

  cmakeFlakgs = [
    (lib.cmakeFeature "BUILD_TESTING" "OFF")
  ];

  meta = with lib; {
    license = licenses.agpl3Plus;
    description = "Various components required by AeroShell-based desktops";
    homepage = "https://github.com/aeroshell-desktop/aeroshell-workspace";
    platforms = platforms.unix;
  };
}
