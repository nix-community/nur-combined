{ pkgs }:

pkgs.python3Packages.buildPythonPackage rec {
	pname = "rich";
	version = "13.9.4";
	pyproject = true;

	src = pkgs.fetchFromGitHub {
		owner = "Textualize";
		repo = "rich";
		tag = "v${version}";
		hash = "sha256-Zaop9zR+Sz9lMQjQP1ddJSid5jEmf0tQYuTeLuWNGA8=";
	};

	build-system = with pkgs; with python3Packages; [
		poetry-core
	];

	dependencies = with pkgs; with python3Packages; [
		markdown-it-py
		pygments
	];

	optional-dependencies = {
		jupyter = with pkgs; [
			ipywidgets
		];
	};

	meta = with pkgs; {
		description = "Render rich text, tables, progress bars, syntax highlighting, markdown and more to the terminal";
		homepage = "https://github.com/Textualize/rich";
		changelog = "https://github.com/Textualize/rich/blob/v${version}/CHANGELOG.md";
		license = lib.licenses.mit;
	};
}
