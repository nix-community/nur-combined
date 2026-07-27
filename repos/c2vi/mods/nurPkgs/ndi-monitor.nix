{ stdenv
, fetchFromGitHub
, lib
, ndi
}:

stdenv.mkDerivation rec {
	pname = "ndi-monitor";
	version = "0.3.2";

	src = fetchFromGitHub {
    owner = "lplassman"; 
		repo = "NDI-Monitor";
    rev = "f4ae6506d308b1b847e449833aa4cea3555caf15";
    sha256 = "sha256-YLNvFdyqKb6DJV/cmdF8O5hmxOOqCCFbwGlFxI6rpW0=";
	};

  patches = [ ./ndi-monitor.patch ];

  nativeBuildInputs = [
    ndi
  ];

  buildPhase = ''
    g++ -std=c++14 -pthread  -Wl,--allow-shlib-undefined -Wl,--as-needed -Iinclude/ -I${ndi}/include/ -L lib -o ndi_monitor ndi_monitor.cpp mongoose.c mjson.c -lndi -ldl
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ndi_monitor $out/bin/ndi-monitor
    cp -r $src/assets $out
  '';
  
  buildInputs = [
    #ncurses
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
