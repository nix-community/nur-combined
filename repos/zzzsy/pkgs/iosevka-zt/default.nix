{ source, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  inherit (source) pname version src;

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    mv TTF/*.ttf $_
  '';
}
