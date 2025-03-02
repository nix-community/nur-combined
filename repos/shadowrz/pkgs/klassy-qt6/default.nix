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

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DBUILD_QT5=OFF"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
  ];

  patches =
    [
      (fetchpatch rec {
        name = "project-version.patch";
        url = "https://aur.archlinux.org/cgit/aur.git/plain/${name}?h=klassy";
        hash = "sha256-y/wtvJw0sObvQtBRD92kOn/25rqiJ/TKG3fhQAdKJBo=";
      })
    ]
    ++ lib.optionals (lib.strings.versionAtLeast kdecoration.version "6.3.0") [
      (fetchpatch {
        name = "kdecorations-6.3.patch";
        url = "https://github.com/paulmcauley/klassy/pull/178.patch";
        hash = "sha256-b6IIyx2ViuLzKAVfoqEN0B5dek8AIJzpNTayxf8Mwqk=";
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
    license = with licenses; [
      gpl2Only
      gpl2Plus
      gpl3Only
      bsd3
      mit
    ];
  };
}
