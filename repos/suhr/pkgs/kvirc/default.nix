{ stdenv, fetchFromGitHub
, pkgconfig, cmake, gettext
, qt5
}:

stdenv.mkDerivation rec {
  name = "kvirc-5.0.84fbb94";
  version = "84fbb9458ddb7c0ecf85df2098fe424005648e27";

  src = fetchFromGitHub {
    owner = "kvirc";
    repo = "KVIrc";
    rev = "84fbb9458ddb7c0ecf85df2098fe424005648e27";
    sha256 = "1z6csx9vzj6b60vy9lj832xh0ghxwjrqyhrwjssd5nnfjqp7ics2";
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
