{ stdenv, fetchFromGitHub
, pkgconfig, cmake, gettext
, qt5
}:

stdenv.mkDerivation rec {
  name = "kvirc-${version}";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "kvirc";
    repo = "KVIrc";
    rev = "${version}";
    sha256 = "1dq7v6djw0gz56rvghs4r5gfhzx4sfg60rnv6b9zprw0vlvcxbn4";
  };

  buildInputs = with qt5; [
    qtbase qtmultimedia qtsvg qtx11extras
  ];

  nativeBuildInputs = [
    pkgconfig cmake gettext
  ];

  meta = with stdenv.lib; {
    description = "Advanced IRC Client";
    homepage = http://www.kvirc.net/;
    license = licenses.gpl2;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
