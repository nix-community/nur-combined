{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  name = "mplus";
  version = "1.0";
  dontConfigue = true;
  src = fetchFromGitHub {
    owner = "coz-m";
    repo = "MPLUS_FONTS";
    rev = "c47fd4ff0a604d1517625a0f3d67e6d64e12d585";
    sha256 = "sha256-xiGMq4oKzga0NUprcSAKYhkQ23ft9c31hLNqs30ugFs=";
  };
  installPhase = ''
    mkdir -p $out/share/fonts
    cp -R $src/fonts/ttf $out/share/fonts/ttf
  '';
  meta = {description = "With the harmony of comfortable curves and straight lines, this font gives modern and generous impression, suiting for any occasions including small texts to big titles. This package also contains M PLUS 2 and the M PLUS coding fonts.";};
}
