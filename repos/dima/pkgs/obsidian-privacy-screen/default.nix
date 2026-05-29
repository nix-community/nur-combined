{ pkgs }:

pkgs.buildNpmPackage {
	pname = "obsidian-privacy-screen";
	version = "0.1.2";

	src = pkgs.fetchFromGitHub {
		owner = "chanhee-lee";
		repo = "obsidian-privacy-screen";
		rev = "0.1.2";
		hash = "sha256-hfHg8LJ9oIJ464NLqT1pxfjCo2+WwbaQlay39kDX0b0=";
	};

	npmDepsHash = "sha256-Ift/wBuj8z1FXMb3qitT4OmQR5tNTcrKDxaFXVtF0S0=";

	installPhase = ''
		mkdir -p $out
		cp main.js styles.css manifest.json $out
	'';

	meta = with pkgs.lib; {
		homepage = "https://github.com/chanhee-lee/obsidian-privacy-screen";
		license = licenses.mit;
		description = "Blur your workspace while keeping a spotlight around your cursor";
	};
}
