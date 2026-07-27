{
  source,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  inherit (source) pname src version;

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    mv TTF/*.ttf $_
  '';
}
