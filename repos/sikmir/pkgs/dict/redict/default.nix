{ mkDerivation
, stdenv
, lib
, fetchFromGitHub
, pkg-config
, qmake
, qtbase
, qtmultimedia
, qtsvg
, qttools
, qtx11extras
, libX11
, libXext
, libXtst
, withI18n ? true
}:

mkDerivation {
  pname = "redict";
  version = "2019-06-21";

  src = fetchFromGitHub {
    owner = "rekols";
    repo = "redict";
    rev = "525aac01ed5fc0f74f8393dc5b5b3bb57c9b0c5f";
    sha256 = "1zlad1bmlyy4hirm93f0744c98y9hg11b32ym06rsax719qj2rjl";
  };

  nativeBuildInputs = [ qmake pkg-config ]
    ++ lib.optional withI18n qttools;
  buildInputs = [ qtmultimedia qtsvg ]
    ++ lib.optionals stdenv.isLinux [ qtx11extras libX11 libXext libXtst ];

  postPatch = ''
    substituteInPlace redict.pro \
      --replace "unix " "unix:!mac "
    sed -i '1i#include <QPainterPath>' src/widgets/spinner.cpp
  '';

  preConfigure = lib.optionalString withI18n ''
    lupdate redict.pro
    lrelease redict.pro
  '';

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
    "BINDIR=${placeholder "out"}/bin"
    "APPDIR=${placeholder "out"}/share/applications"
  ];

  meta = with lib; {
    description = "A dictionary for Linux, based on C++/Qt development";
    homepage = "https://github.com/rekols/redict";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
  };
}
