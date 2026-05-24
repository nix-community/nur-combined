{ pkgs }:
let
	betterMarkDownLinks = pkgs.fetchFromGitHub {
		owner = "mnaoumov";
		repo = "obsidian-better-markdown-links";
		rev = "3.3.1";
		hash = "sha256-4LzHsraZSjmApHH0tb7WRqNwSoU90lD6y9Q3GTc+xVg=";
	};

	patchedSrc = pkgs.stdenv.mkDerivation {
		pname = "obsidian-better-markdown-links-patched";
		version = "3.3.1";
		src = betterMarkDownLinks;
		patches = [ ./fix-lockfile.patch ./skip-lib-check.patch ];

		installPhase = ''
			mkdir -p $out
			cp -r . $out
		'';
	};
in
	pkgs.buildNpmPackage {
		pname = "obsidian-better-markdown-links";
		version = "3.3.1";

		src = patchedSrc;

		npmDepsHash = "sha256-FCgjBLjEN+7d+N5EOX2Fc81rjz5Q7JjXHnWPlAPkYrM=";

		ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
		NODE_OPTIONS = "--openssl-legacy-provider";

		installPhase = ''
			mkdir -p $out/lib
			cp dist/build/main.js dist/build/manifest.json dist/build/styles.css $out/lib
		'';

		meta = with pkgs.lib; {
			description = "Obsidian plugin that adds support for angle bracket links and manages relative links properly";
			license = licenses.mit;
			homepage = "https://github.com/mnaoumov/obsidian-better-markdown-links";
		};
	}
