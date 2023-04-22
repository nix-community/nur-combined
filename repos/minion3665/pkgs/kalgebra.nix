{ analitza
, qt5
, stdenv
, lib
, extra-cmake-modules
}:
let
  hash = "e82b59795985540062f4c00e582dc42e8b8358e8";
in
stdenv.mkDerivation rec {
  version = builtins.substring 0 7 hash;
  src = builtins.fetchGit {
    url = "https://github.com/KDE/kalgebra";
    rev = hash;
  };
  pname = "kalgebra";
  nativeBuildInputs = [ extra-cmake-modules qt5.wrapQtAppsHook ];
  buildInputs = with qt5; with libsForQt5; [
    qtbase
    qtquickcontrols
    kconfig
    kcoreaddons
    kcrash
    kconfigwidgets
    kdbusaddons
    kdoctools
    ktextwidgets
    kxmlgui
    kdeApplications.libkdegames
    kcompletion
    analitza
    kirigami2
  ];

  meta = with lib; {
    description = "an application that can replace your graphing calculator";
    longDescription = ''
      KAlgebra is an application that can replace your graphing calculator. It has numerical, logical, symbolic, and analysis features that let you calculate mathematical expressions on the console and graphically plot the results in 2D or 3D. KAlgebra is rooted in the Mathematical Markup Language (MathML); however, one does not need to know MathML to use KAlgebra.
    '';
    homepage = "https://apps.kde.org/en-gb/kalgebra/";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ minion3665 ];
    broken = true; # Dependency locking issues with extra-cmake-modules
  };
}
