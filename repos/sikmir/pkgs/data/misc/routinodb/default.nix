{ lib, stdenv, fetchurl, routino }:

stdenv.mkDerivation rec {
  pname = "routinodb";
  version = "210816";

  srcs = [
    (fetchurl {
      url = "https://download.geofabrik.de/europe/finland-${version}.osm.pbf";
      hash = "sha256-9nfhxci9Y/XE9I+sRF8Hju6Yg8dLa7epOIwsZVjwazA=";
    })
    (fetchurl {
      url = "https://download.geofabrik.de/europe/estonia-${version}.osm.pbf";
      hash = "sha256-9LSE/vkGKFVtp8InXcXOqzactoUZsunC45iK+Ta18oI=";
    })
    (fetchurl {
      url = "https://download.geofabrik.de/russia/northwestern-fed-district-${version}.osm.pbf";
      hash = "sha256-quHCVQomVPvqskC5YEClJU5Zno9oLiYx6omW1SMmRWk=";
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
