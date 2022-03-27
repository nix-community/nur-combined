{ stdenv
, lib
, sources
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.genshin-glyphs) pname version src;
  installPhase = ''
    mkdir -p $out/share/fonts/opentype/
    cp *.otf $out/share/fonts/opentype/
  '';

  meta = with lib; {
    description = "Constructed scripts in Genshin Impact";
    homepage = "https://github.com/SpeedyOrc-C/Genshin-Glyphs";
    license = licenses.gpl3;
  };
}
