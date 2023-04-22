{ stdenv
, lib
, #qt5-declarative,
  libsForQt5
, extra-cmake-modules
, #kdoctools,
  eigen
, #qt5-tools,
  fetchurl
,
}:
stdenv.mkDerivation {
  pname = "analitza";
  version = "21.12.2";
  dontWrapQtApps = true;

  src = fetchurl {
    url = "https://download.kde.org/stable/release-service/21.12.2/src/analitza-21.12.2.tar.xz";
    sha256 = "a4c52d0ea51870495c2da25a58c7495af14e9d71a380d20aea9c1dd39de762aa";
  };

  buildInputs = [ extra-cmake-modules ];
  nativeBuildInputs = [
    libsForQt5.qt5.qtdeclarative
    libsForQt5.kdoctools
    libsForQt5.qt5.qttools
    eigen
  ];

  meta = with lib; {
    description = "KDE Mathematical Library";
    longDescription = ''
      Analitza is a library that work with mathematical objects. Analitza add mathematical features to your program, such as symbolic computations and some numerical methods; for instance the library can parse mathematical expressions and let you evaluate and draw them.

      Analitza is based on a subset of Mathematical Markup Language (MathML) Version 2.0 so for instance the parser maintains structures that are mapped with a MathML content tag and thus can generate a MathML presentation for the current expression. This means also that all modules of the library are based implicitly on MathML.
    '';
    homepage = "https://api.kde.org/legacy/4.14-api/kdeedu-apidocs/analitza/html/index.html";
    license = licenses.lgpl2Plus;
  maintainers = with maintainers; [ minion3665 ];
  };
}
