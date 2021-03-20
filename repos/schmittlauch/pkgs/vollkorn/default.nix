{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "vollkorn";
  version = "4.105";

  src = fetchzip {
    url = "http://vollkorn-typeface.com/download/vollkorn-4-105.zip";
    sha256 = "1f4bvaj38gs7msihn6vpvnd0zhnkv966l3sh63dsn2dh00dgsvm0";
    stripRoot = false;
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -pv $out/share/{doc/${pname}-${version},fonts/{opentype,truetype,WOFF,WOFF2}}
    cp -v {Fontlog,OFL-FAQ,OFL}.txt $out/share/doc/${pname}-${version}/
    cp -v PS-OTF/*.otf $out/share/fonts/opentype
    cp -v TTF/*.ttf $out/share/fonts/truetype
    cp -v WOFF/*.woff $out/share/fonts/WOFF
    cp -v WOFF2/*.woff2 $out/share/fonts/WOFF2
  '';

  meta = with lib; {
    homepage = "http://vollkorn-typeface.com/";
    description = "The free and healthy typeface for bread and butter use";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = [ maintainers.schmittlauch ];
  };
}
