{ stdenvNoCC
, lib
, fetchurl
, unzip
, ...
} @ args:

stdenvNoCC.mkDerivation rec {
  pname = "oppo-sans";
  version = "0.1";
  src = fetchurl ({
    url = "https://static01.coloros.com/www/public/img/topic7/font-opposans.zip";
    sha256 = "sha256-YrH9EhoT6EIS+tzIAaGzl5J8nYIkNR9bS5O7y0KzrRQ=";
  });
  
  setSourceRoot = "sourceRoot=`pwd`";
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/share/fonts/{opentype,truetype}/
    find . -name '*.otf' -exec install -Dt $out/share/fonts/opentype {} \;
    find . -name '*.ttf' -exec install -Dt $out/share/fonts/truetype {} \;
    find . -name '*.ttc' -exec install -Dt $out/share/fonts/truetype {} \;
  '';
}
