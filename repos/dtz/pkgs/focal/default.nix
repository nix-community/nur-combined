{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig
, wrapGAppsHook, gtk3, libxml2, curl, libsecret, json-glib, gperf, libical
}:

stdenv.mkDerivation rec {
  pname = "focal";
  version = "2019-10-22";
  src = fetchFromGitHub {
    owner = "ohwgiles";
    repo = pname;
    rev = "2dd165a48f91f1c291b71ca12bc8f2d02001fa59";
    sha256 = "0p50za4m9dq0ll0kcg8b80z96adq9pvb7sy699is57mlz90j726d";
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
