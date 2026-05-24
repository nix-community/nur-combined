{ pkgs }:

pkgs.python3Packages.buildPythonPackage {
	pname = "imohash";
	version = "1.1.0";
	src = pkgs.fetchFromGitHub {
		owner = "kalafut";
		repo = "py-imohash";
		rev = "33fb810f03a2abcc519404b8422334e9d6f7af48";
		hash = "sha256-eJlFUBtKZPxJf1HphTRhLUZmOt81vDnynLIRvhpRUv0=";
	};

	format = "pyproject";

	nativeBuildInputs = with pkgs.python3Packages; [
		setuptools
		wheel
	];

	propagatedBuildInputs = with pkgs.python3Packages; [
		mmh3
		varint
	];

	checkInputs = with pkgs.python3Packages; [
		pytest
	];

	checkPhase = ''
		${pkgs.python3Packages.pytest}/bin/pytest
	'';

	meta = with pkgs.lib; {
		mainProgram = "imosum";
		description = "Fast hashing for large files";
		license = licenses.mit;
		homepage = "https://github.com/kalafut/py-imohash";
	};
}
