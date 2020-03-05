{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig
, wrapGAppsHook, gtk3, libxml2, curl, libsecret, json-glib, gperf, libical
}:

stdenv.mkDerivation rec {
  pname = "focal";
  version = "2020-03-05";
  src = fetchFromGitHub {
    owner = "ohwgiles";
    repo = pname;
    rev = "72cfc4b1fcb3bf4fdc43a8ef673b63d984776e8a"; 
    sha256 = "0fqh2r3yzdpwg07rgvf18cw8wdbj36ds5lhwaxwcn6414xbrvzwh";
  };

  patches = [
    ./localtime.patch
    ./gmtime.patch

    ./add-action.patch
    ./new-events-get-actions.patch
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
