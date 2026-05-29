{ pkgs}:
let
	smartTypography = pkgs.fetchFromGitHub {
		owner = "mgmeyers";
		repo = "obsidian-smart-typography";
		rev = "1.0.18";
		hash = "sha256-6uImoDQ9Qgcn+zKk3wLKoFKXoi1LPIfgqA1SjjZPg3I=";
	};

	patchedSrc = pkgs.stdenv.mkDerivation {
		pname = "obsidian-smart-typography-patched";
		version = "1.0.18";
		src = smartTypography;
		patches = [ ./remove-cm-language.patch ];

		installPhase = ''
			mkdir -p $out
			cp -r . $out
		'';
	};

	nodeModules = pkgs.mkYarnPackage {
		pname = "node-modules";
		src = patchedSrc;
	};
in
	pkgs.stdenv.mkDerivation {
		pname = "obsidian-smart-typography";
		version = "1.0.18";

		src = patchedSrc;

		nativeBuildInputs = [
			pkgs.yarn
			nodeModules
		];

		buildPhase = ''
			ln -s ${nodeModules}/libexec/obsidian-sample-plugin/node_modules node_modules
			${pkgs.yarn}/bin/yarn build
		'';

		installPhase = ''
			mkdir -p $out
			cp main.js manifest.json $out
		'';

		meta = with pkgs.lib; {
			homepage = "https://github.com/mgmeyers/obsidian-smart-typography";
			license = licenses.mit;
			description = "Converts quotes to curly quotes, dashes to em dashes, and periods to ellipses";
		};
	}
