{
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation {
  name = "urbanist";
  version = "1.0";
  dontConfigue = true;
  src = fetchzip {
    url = "https://befonts.com/wp-content/uploads/2021/11/Urbanist-master.zip";
    sha256 = "sha256-Bx1Clqk7u0bxDkiqZPX+ZIPC9JtXb6mnbZpDoKUpZys=";
    stripRoot = false;
  };
  installPhase = ''
    mkdir -p $out/share/fonts
    cp -R $src/Urbanist-master/fonts/otf $out/share/fonts/opentype
  '';
  meta = {description = "Urbanist is a low-contrast, geometric sans-serif inspired by Modernist typography and design.";};
}
