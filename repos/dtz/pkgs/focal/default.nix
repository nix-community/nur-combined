{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig
, wrapGAppsHook, gtk3, libxml2, curl, libsecret, json-glib, gperf, libical
}:

stdenv.mkDerivation rec {
  pname = "focal";
  version = "2019-10-26";
  src = fetchFromGitHub {
    owner = "ohwgiles";
    repo = pname;
    rev = "4b165c916d9d4f75418a51c4a92b0275a6999f8f"; 
    sha256 = "0b7zhvlqdq146rzq9fak5afycgv32w2zs9772xr222whc898p3ha";
  };

  patches = [
    ./localtime.patch

    ./0001-caldav-Handle-gracefully-components-containing-no-VE.patch
    ./0002-minor-style-tweaks.patch
    ./0003-caldav-calendar-fix-leak-of-comp-in-parse-failure.patch

    ./app-header-tooltips.patch
    ./event-popup-tooltips.patch

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
