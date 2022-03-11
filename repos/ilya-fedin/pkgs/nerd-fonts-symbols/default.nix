{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "nerd-fonts-symbols";
  version = "unstable-2022-02-24";

  src = fetchurl {
    url = "https://github.com/ryanoasis/nerd-fonts/raw/master/src/glyphs/Symbols-2048-em%20Nerd%20Font%20Complete.ttf";
    name = "nerd-fonts-symbols.ttf";
    sha256 = "sha256-32vlj3cHwOjJvDqiMPyY/o+njPuhytQzIeWSgeyklgA=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -m644 -TD $src "$out/share/fonts/truetype/${pname}/Symbols-2048-em Nerd Font Complete.ttf"
  '';

  meta = with lib; {
    homepage = "https://github.com/ryanoasis/nerd-fonts";
    description = "High number of extra glyphs from popular 'iconic fonts'";
    maintainers = with maintainers; [ ilya-fedin ];
    license = licenses.mit;
    platforms = platforms.all;
  };
}