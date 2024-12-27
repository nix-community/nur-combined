{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  extra-cmake-modules,
  kdecoration,
  kcoreaddons,
  kguiaddons,
  kconfigwidgets,
  kiconthemes,
  kwindowsystem,
  kwayland,
  kirigami,
  frameworkintegration,
  kcmutils,
  wrapQtAppsHook,
  qtsvg,
}:
stdenv.mkDerivation rec {
  pname = "klassy";
  version = "6.2.breeze6.2.1";

  src = fetchFromGitHub {
    owner = "paulmcauley";
    repo = pname;
    rev = version;
    sha256 = "sha256-tFqze3xN1XECY74Gj0nScis7DVNOZO4wcfeA7mNZT5M=";
  };

  cmakeFlags = ["-DBUILD_TESTING=OFF" "-DBUILD_QT5=OFF"];

  nativeBuildInputs = [cmake extra-cmake-modules wrapQtAppsHook];

  patches = [
    (fetchpatch rec {
      name = "project-version.patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/${name}?h=klassy";
      hash = "sha256-y/wtvJw0sObvQtBRD92kOn/25rqiJ/TKG3fhQAdKJBo=";
    })
  ];

  buildInputs = [
    kdecoration
    kcoreaddons
    kguiaddons
    kconfigwidgets
    kiconthemes
    kwayland
    kwindowsystem
    kirigami
    frameworkintegration
    kcmutils
    qtsvg
  ];

  meta = with lib; {
    description = "A highly customizable binary Window Decoration and Application Style plugin for recent versions of the KDE Plasma desktop";
    homepage = "https://github.com/paulmcauley/klassy";
    license = with licenses; [gpl2Only gpl2Plus gpl3Only bsd3 mit];
  };
}
