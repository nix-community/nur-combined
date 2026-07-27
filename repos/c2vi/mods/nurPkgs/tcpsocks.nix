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
		owner = "vi";
		repo = "tcpsocks";
    rev = "e7bf8bdc68a76f5ab22d391c6307ec6a9828b606";
    sha256 = "sha256-nLQloHuFamNwlIJgBmpeh9KEQoAXvoJDvlb7SkWeoDw=";
	};

  nativeBuildInputs = [
  ];
  
  buildInputs = [
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./tcpsocks $out/bin
  '';

  meta = with lib; {
    description = "Redirect traffic to SOCKS5 server with iptables, epoll based, single threaded.";
    longDescription = ''
    '';
    homepage = "https://github.com/vi/tcpsocks";
    license = licenses.gpl2Only;
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
