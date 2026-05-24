{ pkgs, rich-13-9-4, rich-argparse-rich-13-9-4 }:

pkgs.python3Packages.buildPythonPackage {
	pname = "mdremotifier";
	version = "1.0.0";
	src = pkgs.fetchFromGitHub {
		owner = "realazthat";
		repo = "mdremotifier";
		tag = "v1.0.0";
		hash = "sha256-aZn0hstkHSBv7ifEYDfQ5qUKU2wRkj/YtZZdfs26vIw=";
	};

	patches = [
		./remove-bs4.patch
	];

	format = "pyproject";

	nativeBuildInputs = with pkgs.python3Packages; [
		setuptools
		wheel
	];

	propagatedBuildInputs = with pkgs.python3Packages; [
		beautifulsoup4
		types-beautifulsoup4
		colorama
		mistletoe
		rich-13-9-4
		rich-argparse-rich-13-9-4
		soupsieve
		types-colorama
		typing-extensions
	];

	meta = with pkgs.lib; {
		mainProgram = "mdremotifier";
		description = "Make READMEs self contained for publication to sites other than GH, such as npm, pypi, by turning relative images into absolute ones";
		homepage = "https://github.com/realazthat/mdremotifier";
		license = licenses.mit;
	};
}
