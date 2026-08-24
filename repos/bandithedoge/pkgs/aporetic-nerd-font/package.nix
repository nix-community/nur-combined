{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "aporetic-nerd-font";
  version = "0-unstable-2025-10-14";
  src = fetchFromGitHub {
    owner = "Echinoidea";
    repo = "Aporetic-Nerd-Font";
    rev = "88ae58addaa9240cf329b389afb21338748ec749";
    sha256 = "sha256-wvzjwnLeaabfhjZCfGpqolalBslcI5oFAdwuQG9VbBI=";
  };

  buildPhase = ''
    mkdir -p $out/share/fonts/truetype/NerdFonts/Aporetic
    cp *.ttf $out/share/fonts/truetype/NerdFonts/Aporetic
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Nerd Font patch with glyphs of Protesilaos' Aporetic font";
    homepage = "https://github.com/Echinoidea/Aporetic-Nerd-Font";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
