{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig
, wrapGAppsHook, gtk3, libxml2, curl, libsecret, json-glib, gperf, libical
}:

stdenv.mkDerivation rec {
  pname = "focal";
  version = "2019-10-24";
  src = fetchFromGitHub {
    owner = "ohwgiles";
    repo = pname;
    rev = "a21b8710cc602eae729ea7deb60d5b45588ed7bf"; # sync timer PR
    sha256 = "03fq1465bz39b7mylfh8pi1342rjp8jpvjlmmhvr6ikd7xb29w49";
  };

  patches = [
    ./dont-crash-if-calendar-has-vtodos-not-just-vevents.patch
    ./localtime.patch
  ];

  nativeBuildInputs = [ wrapGAppsHook cmake pkgconfig ];
  buildInputs = [
    gtk3 libxml2 curl libsecret json-glib gperf libical
  ];

  meta = with stdenv.lib; {
    description = "Calendar application for Linux with CalDAV";
    license = licenses.gpl3;
    inherit (src.meta) homepage;
    maintainers = with maintainers; [ dtzWill ];
  };
}
