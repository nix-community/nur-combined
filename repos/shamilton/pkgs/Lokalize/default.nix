{ lib
, mkDerivation
, fetchFromGitHub
, cmake
, pkg-config
, extra-cmake-modules
, qtbase
, kactivities
, hunspell
, qtscript
, kross
, breakpointHook
}:

mkDerivation rec {
  pname = "Lokalize";
  version = "24.05.2";

  src = fetchFromGitHub {
    owner = "KDE";
    repo = "lokalize";
    rev = "v${version}";
    sha256 = "sha256-EBl+RTieDfVnfQ1n5aFT8a7vsqNAuOlttoeMR7sZduM=";
  };

  nativeBuildInputs = [ breakpointHook pkg-config extra-cmake-modules cmake  ];

  buildInputs = [ kross qtscript hunspell kactivities qtbase ];

  meta = with lib; {
    description = "Computer-aided translation system";
    longDescription = ''
      Lokalize is the localization tool for KDE software and other
      free and open source software. It is also a general computer-aided
      translation system (CAT) with which you can translate OpenDocument
      files (*.odt). Translate-Toolkit is used internally to extract text
      for translation from .odt to .xliff files and to merge translation
      back into .odt file.
    '';
    homepage = "https://apps.kde.org/lokalize/";
    license = licenses.gpl2Plus;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
