{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig
, wrapGAppsHook, gtk3, libxml2, curl, libsecret, json-glib, gperf, libical
}:

stdenv.mkDerivation rec {
  pname = "focal";
  version = "2019-10-24";
  src = fetchFromGitHub {
    owner = "ohwgiles";
    repo = pname;
    rev = "1250bb0caa8f18c34c60020e0d3ac87ebcbe01b8"; 
    sha256 = "15m8r3qf6sz4iv73xn8h5nrjgqxvb5gpzag8fg8hr7im4dh9ljff";
  };

  patches = [
    ./dont-crash-if-calendar-has-vtodos-not-just-vevents.patch
    ./sync-timer.patch
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
