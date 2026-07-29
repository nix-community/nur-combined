{ pkgs }:
let
	version = "4.1.6";
in
	pkgs.buildNpmPackage {
		pname = "obsidian-better-markdown-links";
		version = version;

		src = pkgs.fetchFromGitHub {
			owner = "mnaoumov";
			repo = "obsidian-better-markdown-links";
			rev = version;
			hash = "sha256-pgmhkay6uoBA2CTJfgrcfF+AHLLQkdZ4O5p81t+y4VE=";
		};

		npmDepsHash = "sha256-JFx0HTJawbD97U/IoYhD8TLCEirFRcuAa0Z68e5ImV8=";

		ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
		NODE_OPTIONS = "--openssl-legacy-provider";

		installPhase = ''
			mkdir -p $out
			cp dist/build/main.js dist/build/manifest.json dist/build/styles.css $out
		'';

		meta = with pkgs.lib; {
			description = "Obsidian plugin that adds support for angle bracket links and manages relative links properly";
			license = licenses.mit;
			homepage = "https://github.com/mnaoumov/obsidian-better-markdown-links";
		};
	}
