{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "my-fonts";
  version = "1.1";

  src = fetchurl {
    url = "https://assets.zzzsy.top/${pname}.tar.xz";
    hash = "sha256-q1ye+wpukSC63D6d+SM4AnmXsqYdqQxRtsfbEnavDew=";
  };
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    mv **/*.otf $_
  '';
}
