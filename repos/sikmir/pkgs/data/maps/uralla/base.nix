{
  lib,
  stdenvNoCC,
  fetchurl,
  pname,
  version,
  sha256,
}:

stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://www.uralla.ru/garmin/topo/topo.${pname}.img";
    inherit sha256;
  };

  dontUnpack = true;

  installPhase = "install -Dm644 $src $out/${pname}.img";

  preferLocalBuild = true;

  meta = {
    description = "Туристические карты для навигаторов Garmin";
    homepage = "https://www.uralla.ru/ural-garmin-topo-img-map-16505.html";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
