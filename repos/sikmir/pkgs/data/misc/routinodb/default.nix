{ lib, stdenv, fetchurl, routino }:

stdenv.mkDerivation rec {
  pname = "routinodb";
  version = "210512";

  srcs = [
    (fetchurl {
      url = "https://download.geofabrik.de/europe/finland-${version}.osm.pbf";
      hash = "sha256-Vw9rG/SgO6gjgqFEwcO1/PJhtYwkTT/QOeMQTiaDQAw=";
    })
    (fetchurl {
      url = "https://download.geofabrik.de/europe/estonia-${version}.osm.pbf";
      hash = "sha256-u7WoFIOx5OH+Sv7WuCw7PucS1Ohxz4GzHX2nmR29rMw=";
    })
    (fetchurl {
      url = "https://download.geofabrik.de/russia/northwestern-fed-district-${version}.osm.pbf";
      hash = "sha256-VxTUUJeqVKmFDbvf9Wd/DtNYoGuD5ZR6dhenVeDBnAg=";
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
