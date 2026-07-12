{ pkgs }:

pkgs.stdenv.mkDerivation {
	pname = "vtt";
	version = "unstable-2021-12-10";

	src = pkgs.fetchFromSourcehut {
		owner = "~hnaguski";
		repo = "vtt";
		rev = "cc011205cd46db16faa51ba6856ca4529d525bee";
		hash = "sha256-68YhhSmuGaKbwj59vK2geNlent9b4Au0Klo83W4XVOo=";
	};

	patches = [
		./customize-cache.patch
	];

	propagatedBuildInputs = with pkgs; [
		jq
		wget
	];

	dontBuild = true;

	installPhase = ''
		mkdir -p $out/bin/
		mkdir -p $out/share/vtt/
		mkdir -p $out/share/zsh/site-functions/_vtt/

		cp -f _vtt $out/share/zsh/site-functions/_vtt/
		cp -rf templates $out/share/vtt/

		cp -f vtu $out/bin
		cp -f vts $out/bin
		cp -f vtd $out/bin
	'';

	meta = with pkgs.lib; {
		homepage = "https://git.sr.ht/~hnaguski/vtt";
		license = licenses.gpl3;
		description = "Scripts to download Minecraft resource packs from vanillatweaks.net";
	};
}
