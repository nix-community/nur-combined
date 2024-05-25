{
  lib,
  stdenvNoCC,
  fetchurl,
  unrar,
  pname,
  version,
  hash,
}:

stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "http://meridian.perm.ru/04_maps/gpsmap/${pname}.rar";
    inherit hash;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unrar ];

  installPhase = "install -Dm644 *.img -t $out";

  preferLocalBuild = true;

  meta = {
    description = "Самодельные векторные карты для GPS-навигаторов";
    homepage = "http://meridian.perm.ru/04_maps/maps_for_gps.shtml";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
