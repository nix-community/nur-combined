{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig
, wrapGAppsHook, gtk3, libxml2, curl, libsecret, json-glib, gperf, libical
}:

stdenv.mkDerivation rec {
  pname = "focal";
  version = "2020-03-07";
  src = fetchFromGitHub {
    owner = "ohwgiles";
    repo = pname;
    rev = "ceb938add77ac50960022512487f22e0769a669c";
    sha256 = "0nl8bciqhrd7ycsqy7l12fr8aislgrffqwlm541k7z8k4bfgq8rh";
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
