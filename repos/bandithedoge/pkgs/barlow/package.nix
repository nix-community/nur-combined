{
  sources,

  lib,
  stdenv,
}:
stdenv.mkDerivation {
  inherit (sources.barlow) pname src;
  version = sources.barlow.date;

  buildPhase = ''
    mkdir -p $out/share/fonts/{truetype,opentype,woff2}
    cp -r fonts/ttf/*.ttf $out/share/fonts/truetype
    cp -r fonts/otf/*.otf $out/share/fonts/opentype
    cp -r fonts/ttf/*.woff2 $out/share/fonts/woff2
  '';

  passthru._ignoreDupe = true;

  meta = {
    description = "Straight-sided sans-serif superfamily";
    homepage = "https://tribby.com/fonts/barlow";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
