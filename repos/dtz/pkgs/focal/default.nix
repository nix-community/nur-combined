{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig
, wrapGAppsHook, gtk3, libxml2, curl, libsecret, json-glib, gperf, libical
}:

stdenv.mkDerivation rec {
  pname = "focal";
  version = "2019-07-25";
  src = fetchFromGitHub {
    owner = "ohwgiles";
    repo = pname;
    rev = "95c527d1ff3d90f5733fb947274b22f324267a10";
    sha256 = "0yiqvg8wfvw2x7k36zaz92qpc8kvpjr3n7v64vik9ibhnhdfzqrv";
  };

  patches = [
    ./dont-crash-if-calendar-has-vtodos-not-just-vevents.patch
    (fetchpatch {
      name = "initially-showing-next-week-instead-of-current.patch";
      url = "https://github.com/ohwgiles/focal/pull/61.diff"; # diff not patch, don't want series
      sha256 = "0r726xgmc6qp6w6fpjc023m4f1i6gdg8kwfjila21fwymna9cygj";
    })
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
