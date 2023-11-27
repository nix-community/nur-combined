{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, ninja
, wrapQtAppsHook
, dolphin
, libgit2
, kconfigwidgets
, kcoreaddons
, kcrash
, kdbusaddons
, kdoctools
, ki18n
, kio
, ktexteditor
, ktextwidgets
, kxmlgui
, syntax-highlighting
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kommit";
  version = "1.3.0";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "kommit";
    rev = "v${finalAttrs.version}";
    hash = "sha256-P+c+iqzyUbdU4U+zE9sFS1vDgZbuNug+j+rbuLTrap4=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    ninja
    wrapQtAppsHook
  ];

  buildInputs = [
    dolphin
    libgit2
    kconfigwidgets
    kcoreaddons
    kcrash
    kdbusaddons
    kdoctools
    ki18n
    kio
    ktexteditor
    ktextwidgets
    kxmlgui
    syntax-highlighting
  ];

  meta = {
    mainProgram = "kommit";
    description = "Graphical Git client for KDE";
    homepage = "https://apps.kde.org/kommit/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
