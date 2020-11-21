{ stdenvNoCC
, lib
, sources
, maptilerApiKey ? ""
, mapboxApiKey ? ""
, thunderforestApiKey ? ""
, openrouteserviceApiKey ? ""
, hereApiKey ? ""
, mapsList ? [
    "World/Asia/nakarte-*.xml"
    "World/Europe/FI"
    "World/Europe/RU"
    "World/CyclOSM.xml"
    "World/MapTiler.xml"
    "World/Mapbox.xml"
    "World/OpenStreetMap.xml"
    "World/heidelberg.xml"
    "World/here-*.xml"
    "World/marshruty.ru.xml"
  ]
}:

stdenvNoCC.mkDerivation {
  pname = "gpxsee-maps";
  version = lib.substring 0 10 sources.gpxsee-maps.date;

  src = sources.gpxsee-maps;

  postPatch = ''
    substitute World/MapTiler.tpl World/MapTiler.xml \
      --replace "insert-your-apikey-here" "${maptilerApiKey}"

    substitute World/Mapbox.tpl World/Mapbox.xml \
      --replace "insert-your-apikey-here" "${mapboxApiKey}"

    substitute World/heidelberg.tpl World/heidelberg.xml \
      --replace "insert-your-apikey-here" "${openrouteserviceApiKey}"

    for m in World/Thundeforest-*.tpl; do
      substitute $m $m.xml \
        --replace "insert-your-apikey-here" "${thunderforestApiKey}"
    done

    for m in World/here-*.tpl; do
      substitute $m $m.xml \
        --replace "insert-your-apikey-here" "${hereApiKey}"
    done
  '';

  installPhase = ''
    install -dm755 $out
    cp -r ${toString mapsList} $out
  '';

  meta = with lib; {
    inherit (sources.gpxsee-maps) description homepage;
    license = licenses.unlicense;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
