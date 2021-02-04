{ lib, stdenv, sources, routino }:
let
  year = lib.substring 0 2 sources.geofabrik-russia-nwfd.version;
  month = lib.substring 2 2 sources.geofabrik-russia-nwfd.version;
  day = lib.substring 4 2 sources.geofabrik-russia-nwfd.version;
in
stdenv.mkDerivation {
  pname = "routinodb";
  version = "20${year}-${month}-${day}";

  srcs = [
    sources.geofabrik-finland
    sources.geofabrik-estonia
    sources.geofabrik-russia-nwfd
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
    description = "Routino Database";
    homepage = "https://download.geofabrik.de/index.html";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
