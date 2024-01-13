{
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation {
  name = "gabarito";
  version = "1.0";
  dontConfigue = true;
  src = fetchzip {
    url = "https://github.com/naipefoundry/gabarito/releases/download/v1.000/gabarito-fonts.zip";
    sha256 = "sha256-GOV/iBWsk9owPQ7A0JDfQEZhCiUXgK3O4IEhhjZoJvE=";
    stripRoot = false;
  };
  installPhase = ''
    mkdir -p $out/share/fonts
    cp -R $src/gabarito-fonts/fonts/ttf $out/share/fonts/ttf
  '';
  meta = {description = "Gabarito is a light-hearted geometric sans typeface with 6 weights ranging from Regular to Black originally designed for an online learning platform in Brazil.";};
}
