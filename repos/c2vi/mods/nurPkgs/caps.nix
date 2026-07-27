{ stdenv
, fetchFromGitHub
, ncurses
, autoreconfHook
, lib
}:

stdenv.mkDerivation rec {
	pname = "caps";
	version = "master";

	src = fetchFromGitHub {
		owner = "jhunt";
		repo = "caps";
    rev = "d0c499a351edd2c1fd9a59655d32789078c8eba1";
    sha256 = "sha256-qotSsgHTYSmAINuVA4phJCbOtOehR1CMLwGSPXyqTX8=";
	};

  installPhase = ''
    mkdir -p $out/bin
    cp ./caps $out/bin
  '';

  meta = with lib; {
    description = "A small tool to parse linux capabilities";
    longDescription = ''
      caps is a utility I wrote to make sense of the Linux Capability bitflags you get from the lovely /proc filesystem, which look like: sudo cat /proc/self/status | grep Cap
      CapInh:  0000000000000000
      CapPrm:  0000003fffffffff
      CapEff:  0000003fffffffff
      CapBnd:  0000003fffffffff
      CapAmb:  0000000000000000
    '';
    homepage = "https://github.com/jhunt/caps";
    license = licenses.mit;
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
