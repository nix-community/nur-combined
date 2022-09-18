{ stdenvNoCC
, lib
, sources
, ...
} @ args:

stdenvNoCC.mkDerivation rec {
  inherit (sources.hoyo-glyphs) pname version src;
  installPhase = ''
    mkdir -p $out/share/fonts/opentype/
    cp font/**/*.otf $out/share/fonts/opentype/
  '';

  meta = with lib; {
    description = "Constructed scripts by Hoyoverse 米哈游的架空文字 ";
    homepage = "https://github.com/SpeedyOrc-C/Hoyo-Glyphs";
  };
}
