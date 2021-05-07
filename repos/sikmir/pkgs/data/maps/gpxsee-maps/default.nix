{ lib
, stdenvNoCC
, fetchFromGitHub
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
  version = "2021-04-03";

  src = fetchFromGitHub {
    owner = "tumic0";
    repo = "GPXSee-maps";
    rev = "5adba63fbb5d3919671454d32c802bc1a26c5308";
    hash = "sha256-pEEpcHl4d6lNHWFlxJot8/swUuE7g6mJSbwhUNbUv5k=";
  };

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
    description = "GPXSee maps";
    homepage = "https://tumic0.github.io/GPXSee-maps/";
    license = licenses.unlicense;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
