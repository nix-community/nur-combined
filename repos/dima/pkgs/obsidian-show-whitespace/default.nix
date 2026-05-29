{ pkgs }:
let
	showWhitespace = pkgs.fetchFromGitHub {
		owner = "ebullient";
		repo = "obsidian-show-whitespace-cm6";
		rev = "0.2.8";
		hash = "sha256-vdlax/BjQK8M2LRUokPGPeCHdVnwGE5faM7frYSZ7m4=";
	};

	patchedSrc = pkgs.stdenv.mkDerivation {
		pname = "obsidian-show-whitespace-patched";
		version = "0.2.8";
		src = showWhitespace;

		patches = [ ./remove-cm-language.patch ];

		installPhase = ''
			mkdir -p $out
			cp -r . $out
		'';
	};
in
	pkgs.buildNpmPackage {
		pname = "obsidian-show-whitespace";
		version = "0.2.8";

		src = patchedSrc;

		npmDepsHash = "sha256-oNQbDk3CvO1yMKUnAzTgj+MT2W1T/QnLDB+Rcu8g6TQ=";

		buildPhase = ''
			npm run build --ignore-scripts
		'';

		installPhase = ''
			mkdir -p $out
			cp build/main.js build/styles.css manifest.json $out
		'';

		meta = with pkgs.lib; {
			description = "CSS styles and CM6 extensions to highlight whitespace in Source and Live Preview modes";
			license = licenses.agpl3Only;
			homepage = "https://github.com/ebullient/obsidian-show-whitespace-cm6";
		};
	}
