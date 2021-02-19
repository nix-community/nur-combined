{ lib, stdenvNoCC, fetchurl, unrar, pname, version, sha256 }:

stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "http://meridian.perm.ru/04_maps/gpsmap/${pname}.rar";
    inherit sha256;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unrar ];

  installPhase = "install -Dm644 *.img -t $out";

  preferLocalBuild = true;

  meta = with lib; {
    description = "Самодельные векторные карты для GPS-навигаторов";
    homepage = "http://meridian.perm.ru/04_maps/maps_for_gps.shtml";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
