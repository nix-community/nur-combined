{ lib, stdenv, fetchurl, routino }:

stdenv.mkDerivation rec {
  pname = "routinodb";
  version = "220526";

  srcs = [
    (fetchurl {
      url = "https://download.geofabrik.de/europe/finland-${version}.osm.pbf";
      hash = "sha256-4B5MiJmxdINv250Zc7GvLvEJvtw2pdyoMjJao6w887A=";
    })
    (fetchurl {
      url = "https://download.geofabrik.de/europe/estonia-${version}.osm.pbf";
      hash = "sha256-mdpjbRn+acXlOsld/iiXIgSg+4HK7f1H+nLImoxvk5E=";
    })
    (fetchurl {
      url = "https://download.geofabrik.de/russia/northwestern-fed-district-${version}.osm.pbf";
      hash = "sha256-outJex8qve/UzUv+9lLsnXDTvkIQ4scjPjw8v1Fk1ak=";
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
