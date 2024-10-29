{
  stdenvNoCC,
  lib,
  fetchurl,
  unzip,
  ...
}:

stdenvNoCC.mkDerivation {
  pname = "oppo-sans";
  version = "0.1";
  src = fetchurl ({
    url = "https://static01.coloros.com/www/public/img/topic7/font-opposans.zip";
    sha256 = "sha256-dMGIAyANXCRbwkYJxNlSxOeilFpCrQ3QkRDbkAqVZxA=";
  });

  setSourceRoot = "sourceRoot=`pwd`";
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/share/fonts/{opentype,truetype}/
    find . -name '*.otf' -exec install -Dt $out/share/fonts/opentype {} \;
    find . -name '*.ttf' -exec install -Dt $out/share/fonts/truetype {} \;
    find . -name '*.ttc' -exec install -Dt $out/share/fonts/truetype {} \;
  '';
  meta = with lib; {
    description = ''
      a new typeface designed by Oppo for use in the 
      company's brand identity and as the official font in ColorOS
    '';
    homepage = "https://open.oppomobile.com/bbs/forum.php?mod=viewthread&tid=2274";
    #    maintainers = with maintainers; [ oluceps ];
  };
}
