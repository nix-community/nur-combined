{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "sthkd";
  version = "2020-11-15";

  src = fetchFromGitHub {
    owner = "jeremybobbin";
    repo = "sthkd";
    rev = "2cb198a8e0bc46b9e88c4a7b0f533b35d197a8f0";
    hash = "sha256-P7RWdsxYv/P7K+BfvzkOzCCSMppSxacKVj19MPgeV7I=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Simple Terminal Hotkey Daemon";
    inherit (src.meta) homepage;
    license = licenses.isc;
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
}
