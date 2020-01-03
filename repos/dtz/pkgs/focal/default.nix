{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig
, wrapGAppsHook, gtk3, libxml2, curl, libsecret, json-glib, gperf, libical
}:

stdenv.mkDerivation rec {
  pname = "focal";
  version = "2020-01-03";
  src = fetchFromGitHub {
    owner = "ohwgiles";
    repo = pname;
    rev = "09715f6662f332de312bafc42a743465e9878596"; 
    sha256 = "0b4giadhr07hq6rbwhym556i2iicvbfyf0vdg7q9d72l8bvxia1f";
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
