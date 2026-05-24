{ pkgs }:

pkgs.python3Packages.buildPythonPackage {
	pname = "codemaxxing";
	version = "unstable-2026-04-13";
	src = pkgs.fetchFromGitHub {
		owner = "jshchnz";
		repo = "codemaxxing";
		rev = "d24061c6cea7e85baba008d54f2b572954f4cd2d";
		hash = "sha256-G1w4ldV97ajwjTKgQJY4kDU6axHMJSpYXYXH5YbJsrs=";
	};

	format = "pyproject";

	nativeBuildInputs = with pkgs; with python3Packages; [
		setuptools
	];

	meta = with pkgs.lib; {
		description = "World's first artisanally handcrafted, enterprise-grade slop generation CLI tool for maximizing your GitHub contribution graph";
		homepage = "https://github.com/jshchnz/codemaxxing";
		license = licenses.mit;
		mainProgram = "codemaxxing";
	};
}
