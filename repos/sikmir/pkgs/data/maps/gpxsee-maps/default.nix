{ lib
, stdenvNoCC
, fetchFromGitHub
, hereApiKey ? ""
, mapboxApiKey ? ""
, maptilerApiKey ? ""
, mmlApiKey ? ""
, openrouteserviceApiKey ? ""
, thunderforestApiKey ? ""
, mapsList ? [
    "World/Asia/nakarte-*.xml"
    "World/Europe/FI/*.xml"
    "World/Europe/RU/*.xml"
    "World/CyclOSM.xml"
    "World/Inkatlas-Outdoor.xml"
    "World/MapTiler.xml"
    "World/Mapbox.xml"
    "World/OPNVKarte.xml"
    "World/OpenStreetMap.xml"
    "World/heidelberg.xml"
    "World/here-*.xml"
    "World/marshruty.ru.xml"
  ]
}:

stdenvNoCC.mkDerivation {
  pname = "gpxsee-maps";
  version = "2021-11-10";

  src = fetchFromGitHub {
    owner = "tumic0";
    repo = "GPXSee-maps";
    rev = "963ce1b7a6718f8368342da3e36f4493f2535e57";
    hash = "sha256-6SEv+TyAwVLRvKg+iWN4JMCXfhx1GlZq6nHG3yUmGIg=";
  };

  postPatch = let
    insertApiKey = map: key: ''
      substitute ${map}.{tpl,xml} \
        --replace "insert-your-apikey-here" "${key}"
    '';
  in
  ''
    ${insertApiKey "World/Europe/FI/Ilmakuva" mmlApiKey}
    ${insertApiKey "World/Europe/FI/Maastokartta" mmlApiKey}
    ${insertApiKey "World/Europe/FI/Selkokartta" mmlApiKey}
    ${insertApiKey "World/Europe/FI/Taustakartta" mmlApiKey}
    ${insertApiKey "World/here-base" hereApiKey}
    ${insertApiKey "World/here-vector" hereApiKey}
    ${insertApiKey "World/heidelberg" openrouteserviceApiKey}
    ${insertApiKey "World/MapTiler" maptilerApiKey}
    ${insertApiKey "World/Mapbox" mapboxApiKey}
    ${insertApiKey "World/Thunderforest-Landscape" thunderforestApiKey}
    ${insertApiKey "World/Thunderforest-Neighbourhood" thunderforestApiKey}
    ${insertApiKey "World/Thunderforest-OpenCycleMap" thunderforestApiKey}
    ${insertApiKey "World/Thunderforest-Outdoors" thunderforestApiKey}
    ${insertApiKey "World/Thunderforest-Transport" thunderforestApiKey}
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
  };
}
