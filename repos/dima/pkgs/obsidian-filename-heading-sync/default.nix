{ pkgs }:
let
	revision = "1.11.0";
in
	pkgs.buildNpmPackage {
		pname = "obsidian-filename-heading-sync";
		version = revision;

		src = pkgs.fetchFromGitHub {
			owner = "dvcrn";
			repo = "obsidian-filename-heading-sync";
			rev = revision;
			hash = "sha256-1iu/Q8ENDIT8faL0gIn0lzKJRAP1WjnY4I8WQfVkHYc=";
		};

		npmDepsHash = "sha256-SpEupcKiDa4VBADQxklSLAYdLr/w6p34n1cA9nMTj4o=";

		npmFlags = [
			"--ignore-scripts"
		];

		installPhase = ''
			mkdir -p $out
			cp build/main.js build/manifest.json $out
		'';

		meta = with pkgs.lib; {
			description = "Obisdian.md plugin to keep the filename and the first header of the file in sync";
			homepage = "https://github.com/dvcrn/obsidian-filename-heading-sync";
			license = licenses.mit;
		};
	}
