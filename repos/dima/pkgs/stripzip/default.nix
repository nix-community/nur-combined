{ pkgs }:

pkgs.stdenv.mkDerivation rec {
	pname = "stripzip";
	version = "unstable-2016-02-11";

	src = pkgs.fetchFromGitHub {
		owner = "KittyHawkCorp";
		repo = "stripzip";
		rev = "d55bce7ead2711328e2867adad28c908add62a3a";
		hash = "sha256-AtQhakUpGL2tL9CQMXmq2aB3aLwK5dE7mm/hR4TauP4=";
	};

	installPhase = ''
		mkdir -p $out/bin

		mv ${pname} $out/bin
	'';

	meta = with pkgs.lib; {
		description = "Utility to remove metadata from ZIP files";
		homepage = "https://github.com/KittyHawkCorp/stripzip";
		license = licenses.bsd2;
		mainProgram = pname;
	};
}
