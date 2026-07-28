{ pkgs }:
let
	showWhitespace = pkgs.fetchFromGitHub {
		owner = "ebullient";
		repo = "obsidian-show-whitespace-cm6";
		rev = "0.2.14";
		hash = "sha256-WTJv/1SreVY/aPUhLcKoL3Dzl2SNsc6S/FNgERNMVhA=";
	};

	patchedSrc = pkgs.stdenv.mkDerivation {
		pname = "obsidian-show-whitespace-patched";
		version = "0.2.14";
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
		version = "0.2.14";

		src = patchedSrc;

		npmDepsHash = "sha256-+PHCaMi0ir+BbioZD809Tt4ObWfY5cOV/HCsplN28M4=";

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
