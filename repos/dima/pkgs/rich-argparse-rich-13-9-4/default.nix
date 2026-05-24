{ pkgs, rich-13-9-4 }:

pkgs.python3Packages.buildPythonPackage rec {
	pname = "rich-argparse";
	version = "1.7.1";
	pyproject = true;

	src = pkgs.fetchFromGitHub {
		owner = "hamdanal";
		repo = "rich-argparse";
		tag = "v${version}";
		hash = "sha256-gLXFiWgGMDOUbTyoSgTr0XfotVfDxwMqPdsfE4KHzXM=";
	};

	build-system = with pkgs; with python3Packages; [
		hatchling
	];

	dependencies = [
		rich-13-9-4
	];

	meta = with pkgs; {
		description = "Format argparse help output using rich";
		homepage = "https://github.com/hamdanal/rich-argparse";
		changelog = "https://github.com/hamdanal/rich-argparse/blob/${src.tag}/CHANGELOG.md";
		license = lib.licenses.mit;
	};
}
