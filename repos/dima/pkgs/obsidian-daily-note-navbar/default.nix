{ pkgs }:

pkgs.buildNpmPackage rec {
	pname = "obsidian-daily-note-navbar";
	version = "0.2.1";

	src = pkgs.fetchFromGitHub {
		owner = "karstenpedersen";
		repo = pname;
		rev = version;
		hash = "sha256-cDm8SXdudIO5Vtz34uhgP+ZladReBDcz0HJWSE0Gj8I=";
	};

	npmDepsHash = "sha256-OkGU9eoIgfqUjJpv9kHN4qyWvn6C5fMEvAexsHWGNb0=";

	makeCacheWritable = true;

	buildPhase = ''
		node esbuild.config.mjs production
	'';

	installPhase = ''
		mkdir -p $out
		cp main.js styles.css manifest.json $out
	'';

	meta = with pkgs.lib; {
		description = "Adds a daily note navbar to quickly navigate between sequential daily notes in Obsidian";
		license = licenses.mit;
		homepage = "https://github.com/karstenpedersen/obsidian-daily-note-navbar";
	};
}
