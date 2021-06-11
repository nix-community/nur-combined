{ lib, stdenv, fetchurl, routino }:

stdenv.mkDerivation rec {
  pname = "routinodb";
  version = "210609";

  srcs = [
    (fetchurl {
      url = "https://download.geofabrik.de/europe/finland-${version}.osm.pbf";
      hash = "sha256-L5l1kD1akfQVw6JM6T9eDc2eL0/yXwRclccsivhaIcI=";
    })
    (fetchurl {
      url = "https://download.geofabrik.de/europe/estonia-${version}.osm.pbf";
      hash = "sha256-pdTKnYC+NpPWzdLsX8QUGe8E3EjKodBh4Nq+q8ffgVE=";
    })
    (fetchurl {
      url = "https://download.geofabrik.de/russia/northwestern-fed-district-${version}.osm.pbf";
      hash = "sha256-iWuA3Lg3JzaKA4ru8rNH9LjN3dDysEMviXID9O40kao=";
    })
  ];

  dontUnpack = true;

  installPhase = ''
    install -dm755 $out

    for src in $srcs; do
      ${routino}/bin/planetsplitter \
        --dir=$out \
        --prefix=RussiaNW \
        --tagging=${routino}/share/routino/tagging.xml \
        --parse-only --append $src
    done

    ${routino}/bin/planetsplitter \
      --dir=$out \
      --prefix=RussiaNW \
      --tagging=${routino}/share/routino/tagging.xml \
      --process-only
  '';

  meta = with lib; {
    description = "Routino Database (FIN+EST+NWFD)";
    homepage = "https://download.geofabrik.de/index.html";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
