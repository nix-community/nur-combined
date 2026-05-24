{ pkgs, imohash }:

pkgs.python3Packages.buildPythonPackage {
	pname = "hashdir";
	version = "0.24";
	src = pkgs.fetchFromGitHub {
		owner = "ozancivaner";
		repo = "hashdir";
		rev = "74a5ff7319fc02ff5f9a63c51771fbfface446ec";
		hash = "sha256-1/NSfHlzOqkJtYqzgYYiqYsMorx1FwViIMPsw+ALV5s=";
	};

	format = "setuptools";

	nativeBuildInputs = with pkgs.python3Packages; [
		setuptools
		wheel
	];

	propagatedBuildInputs = [
		imohash
	];

	meta = with pkgs.lib; {
		mainProgram = "hashdir";
		description = "Command line tool to calculate hashes of directory trees using various hash algorithms";
		license = licenses.mit;
		homepage = "https://github.com/ozancivaner/hashdir";
	};
}
