{ lib, stdenv, fetchFromGitHub, libX11, libXScrnSaver, libXext }:

stdenv.mkDerivation rec {
	pname = "xss-events";
	version = "0.1";

	src = fetchFromGitHub {
		owner = "ondt";
		repo = pname;
		rev = "v${version}";
		sha256 = "18cid2hzkcpjv35fwhlwz3b0p4vyghy3h56pldpzq2mbyasjqvrw";
	};

	buildInputs = [ libX11 libXScrnSaver libXext ];

	installPhase = ''
		mkdir -p $out/bin
		cp xss-events $out/bin
	'';

	meta = with lib; {
		description = "A simple X11 ScreenSaver event listener";
		homepage = "https://github.com/ondt/xss-events";
		license = licenses.mit;
		platforms = platforms.linux;
	};
}
