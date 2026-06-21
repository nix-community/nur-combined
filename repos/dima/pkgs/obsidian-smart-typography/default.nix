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
in
	pkgs.stdenv.mkDerivation rec {
		pname = "obsidian-smart-typography";
		version = "1.0.18";

		src = patchedSrc;

		nativeBuildInputs = with pkgs; [
			nodejs
			yarnConfigHook
			yarnBuildHook
		];

		yarnOfflineCache = pkgs.fetchYarnDeps {
			yarnLock = "${src}/yarn.lock";
			hash = "sha256-p0xqCXFsyRb5CVYd1axqW/6fd0S8+7spch3afVIrem0=";
		};

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
