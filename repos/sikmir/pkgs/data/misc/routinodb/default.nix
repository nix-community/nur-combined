{ lib, stdenv, fetchurl, routino }:

stdenv.mkDerivation rec {
  pname = "routinodb";
  version = "211001";

  srcs = [
    (fetchurl {
      url = "https://download.geofabrik.de/europe/finland-${version}.osm.pbf";
      hash = "sha256-7VSARH9l/gqI8Z6MdpR5fI6aUe82TNXpxf5WgxbvruI=";
    })
    (fetchurl {
      url = "https://download.geofabrik.de/europe/estonia-${version}.osm.pbf";
      hash = "sha256-6TqVk7nMdtGOVmGEh70x5MyZdoOmC3sAB0jIjYpskdI=";
    })
    (fetchurl {
      url = "https://download.geofabrik.de/russia/northwestern-fed-district-${version}.osm.pbf";
      hash = "sha256-BK0T5GHNHVqeTrfdDf1jUDGCSNtgWhxDURQsiDIwoIo=";
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
