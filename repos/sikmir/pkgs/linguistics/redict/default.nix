{ stdenv
, lib
, fetchFromGitHub
, wrapQtAppsHook
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

stdenv.mkDerivation rec {
  pname = "redict";
  version = "2019-06-21";

  src = fetchFromGitHub {
    owner = "rekols";
    repo = "redict";
    rev = "525aac01ed5fc0f74f8393dc5b5b3bb57c9b0c5f";
    hash = "sha256-VGYhcQqnK50NqF6MFcKDyaPECDnAjVRzhMR7Wldoiv4=";
  };

  nativeBuildInputs = [ qmake pkg-config wrapQtAppsHook ]
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
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
  };
}
