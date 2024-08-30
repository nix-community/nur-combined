{ stdenv
, fetchFromGitHub
, autoreconfHook
, lib
, openssl
}:

stdenv.mkDerivation rec {
	pname = "mac-telnet";
	version = "0.5.1";

	src = fetchFromGitHub {
		owner = "haakonnessjoen";
		repo = "MAC-Telnet";
    rev = "v${version}";
    sha256 = "sha256-8DgVlxvRHh5u0Tl9K0i1m7DUqg9h7uL94M7ZaBx3c5s=";
	};

	nativeBuildInputs = [
    autoreconfHook
	];
  buildInputs = [
    openssl
  ];

  configureFlags = [
    "--without-config"
  ];

  meta = with lib; {
    description = "Open source MAC Telnet client and server for connecting to Mikrotik RouterOS routers and Posix devices using MAC addresses";
    homepage = "http://lunatic.no/2010/10/routeros-mac-telnet-application-for-linux-users/";
    license = licenses.gpl2Only;
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
