{ stdenv
, sources
, maptilerApiKey ? ""
, mapboxApiKey ? ""
}:

stdenv.mkDerivation {
  pname = "gpxsee-maps";
  version = stdenv.lib.substring 0 7 sources.gpxsee-maps.rev;
  src = sources.gpxsee-maps;

  postPatch = ''
    substitute World/MapTiler.tpl World/MapTiler.xml \
      --replace "insert-your-apikey-here" "${maptilerApiKey}"
    substitute World/Mapbox.tpl World/Mapbox.xml \
      --replace "insert-your-apikey-here" "${mapboxApiKey}"
  '';

  installPhase = ''
    install -dm755 $out/share/gpxsee/maps
    cp -r World $out/share/gpxsee/maps
    find $out -name "*.tpl" | xargs rm
  '';

  meta = with stdenv.lib; {
    inherit (sources.gpxsee-maps) description homepage;
    license = licenses.unlicense;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
