{ lib, stdenv, fetchFromGitHub, libX11, libXfixes, libXext }:

stdenv.mkDerivation rec {
	pname = "xvisbell";
	version = "0.1";

	src = fetchFromGitHub {
		owner = "ondt";
		repo = pname;
		rev = "v${version}";
		sha256 = "0vmvd7g18qz8mrnrrkw8snvdhkq12sx22scy8ak89clb41yif35q";
	};

	buildInputs = [ libX11 libXfixes libXext ];

	installPhase = ''
		mkdir -p $out/bin
		cp xvisbell $out/bin
	'';

	meta = with lib; {
		description = "Visual Bell for X11";
		homepage = "https://github.com/ondt/xvisbell";
		license = licenses.gpl3Only;
		platforms = platforms.linux;
	};
}
