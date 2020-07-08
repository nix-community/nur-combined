{ stdenv, sources, routino }:

stdenv.mkDerivation {
  pname = "qmapshack-routinodb";
  version = sources.geofabrik-russia-nwfd.version;
  srcs = [
    sources.geofabrik-finland
    sources.geofabrik-estonia
    sources.geofabrik-russia-nwfd
  ];

  preferLocalBuild = true;

  dontUnpack = true;

  installPhase = ''
    install -dm755 $out/share/qmapshack/Routino

    for src in $srcs; do
      ${routino}/bin/planetsplitter \
        --dir="$out/share/qmapshack/Routino" \
        --prefix=RussiaNW \
        --tagging=${routino}/share/routino/tagging.xml \
        --parse-only --append $src
    done

    ${routino}/bin/planetsplitter \
      --dir="$out/share/qmapshack/Routino" \
      --prefix=RussiaNW \
      --tagging=${routino}/share/routino/tagging.xml \
      --process-only
  '';

  meta = with stdenv.lib; {
    description = "Routino Database";
    homepage = "https://download.geofabrik.de/index.html";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
