{ stdenv
, fetchFromGitHub
, ncurses
, autoreconfHook
, lib
}:

stdenv.mkDerivation rec {
	pname = "cbm";
	version = "0.3.2";

	src = fetchFromGitHub {
		owner = "resurrecting-open-source-projects";
		repo = "cbm";
    rev = "eadfbba067ea2c239bd8513be7483c0485f1ba1a";
    sha256 = "sha256-h6q5LsN/GIoQ8Wl+0pyIC/zijHLgcrOdMg2/oayFEV8=";
	};

  nativeBuildInputs = [
    autoreconfHook
  ];
  
  buildInputs = [
    ncurses
  ];

  meta = with lib; {
    description = "A small pogram to display network traffic of interfaces in realtime";
    longDescription = ''
      Simple curses-based GUI.

      It is useful for Internet or LAN speed tests, measuring the velocity of a link, to establish a benchmark or to monitor your connections.

      CBM can be used with virtual, wired or wireless networks.

      Originally imported from some tarballs from the Debian Project: http://snapshot.debian.org/package/cbm/. Now maintained by volunteers.
    '';
    homepage = "https://github.com/resurrecting-open-source-projects/cbm";
    license = licenses.gpl2Only;
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
