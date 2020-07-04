{ lib
, mkDerivation
, makeWrapper
, fetchurl
, cmake
, extra-cmake-modules
, qtbase
, qtquickcontrols2
, qtdeclarative
, qtgraphicaleffects
, kirigami2
, oathToolkit
, ki18n
, libsodium
}:
mkDerivation rec {

  pname = "keysmith";
  version = "0.2";

  src = fetchurl {
    url = "https://github.com/KDE/keysmith/archive/v${version}.tar.gz";
    sha256 = "sha256:0yzs6p3fkpqyl35x4rq0mdgf3hggl1f1zrsal05j4jc0wvg4cd3q";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules makeWrapper ];

  buildInputs = [ libsodium ki18n kirigami2 qtquickcontrols2 qtbase ];

  meta = with lib; {
    description = "OTP client for Plasma Mobile and Desktop";
    license = licenses.gpl3;
    homepage = "https://github.com/KDE/keysmith";
    maintainers = with maintainers; [ shamilton ];
    platforms = platforms.linux;
  };
}
