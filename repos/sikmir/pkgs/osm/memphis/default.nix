{ lib, stdenv, fetchFromGitHub, autoreconfHook, gtk-doc, pkg-config
, cairo, expat, glib
}:

stdenv.mkDerivation rec {
  pname = "memphis";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "jiuka";
    repo = "memphis";
    rev = version;
    hash = "sha256-mBRu2EHEuoHz3scoVaYqAMBZXbG7XkKwdHe9O0gaDBk=";
  };

  nativeBuildInputs = [
    autoreconfHook
    gtk-doc
    pkg-config
  ];

  buildInputs = [
    cairo
    expat
    glib
  ];

  meta = with lib; {
    description = "Map-rendering for OpenStreetMap";
    inherit (src.meta) homepage;
    license = licenses.lgpl2Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
