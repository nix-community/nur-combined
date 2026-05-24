{ pkgs }:

pkgs.python3Packages.buildPythonPackage {
	pname = "nbt";
	version = "1.5.1";
	src = pkgs.fetchFromGitHub {
		owner = "twoolie";
		repo = "NBT";
		rev = "version-1.5.1";
		hash = "sha256-qfm+1uVXmXGVx5qxuvq4fRZjz6R7c/5xLDZUFNiRdag=";
	};

	format = "pyproject";

	nativeBuildInputs = with pkgs; with python3Packages; [
		setuptools
	];

	meta = with pkgs.lib; {
		description = "Python Parser/Writer for the NBT file format, and it's container the RegionFile";
		license = licenses.mit;
		homepage = "https://github.com/twoolie/nbt";
	};
}
