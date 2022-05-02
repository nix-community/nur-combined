{ stdenv
, lib
, sources
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.genshin-glyphs) pname version src;
  installPhase = ''
    mkdir -p $out/share/fonts/opentype/
    cp font/InazumaNeue/InazumaNeue-Regular-0.5.0.otf $out/share/fonts/opentype/
    cp font/KhaenriahNeue/KhaenriahNeue-Chasm-2.0.0.otf $out/share/fonts/opentype/
    cp font/KhaenriahNeue/KhaenriahNeue-Regular-2.0.0.otf $out/share/fonts/opentype/
  '';

  meta = with lib; {
    description = "Constructed scripts in Genshin Impact";
    homepage = "https://github.com/SpeedyOrc-C/Genshin-Glyphs";
    license = licenses.gpl3;
  };
}
