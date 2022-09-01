{ lib, fetchurl, fetchymaps, fetchwebarchive, jq, gdal }:

{
  geocachingSu = fetchwebarchive {
    name = "geocaching_su-2022-01-31";
    url = "https://nakarte.me/geocachingSu/geocaching_su2.json";
    timestamp = "20220131071819";
    hash = "sha256-aN9uX74SISK8UTUYhEhmYKEa9LRtt36t7DQepWFwMIA=";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = ''
      install -dm755 $out
      cat $downloadedFile | \
        ${jq}/bin/jq -r '.[]|[.[3],.[2],.[0]]|@csv' > $out/geocaching.su.csv
    '';

    meta = with lib; {
      homepage = "https://geocaching.su/";
      description = "Geocaches";
      maintainers = [ maintainers.sikmir ];
      license = licenses.free;
      platforms = platforms.all;
    };
  };

  laavut = fetchurl {
    name = "laavut-2021-11-16";
    url = "http://laavu.org/lataa.php?paikkakunta=kaikki";
    hash = "sha256-cazLb7IE1UkUlxbXS1AI3INM/yqZlKd4j8cWehYsmSo=";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = "install -Dm644 $downloadedFile $out/Laavut-kodat.gpx";

    meta = with lib; {
      homepage = "http://laavu.org/";
      description = "Laavut ja kodat kartalla";
      maintainers = [ maintainers.sikmir ];
      license = licenses.free;
      platforms = platforms.all;
      skip.ci = true;
    };
  };

  autiotuvat = fetchurl {
    name = "autiotuvat-2021-11-10";
    url = "http://www.laavu.org/autiotuvat/lataa.php?paikkakunta=kaikki";
    hash = "sha256-Brjh07b0VLhtnukqkRUym/DX30Fygc736ZKnOu6liMU=";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = "install -Dm644 $downloadedFile $out/Autiotuvat.gpx";

    meta = with lib; {
      homepage = "http://www.laavu.org/autiotuvat/";
      description = "Autiotuvat kartalla";
      maintainers = [ maintainers.sikmir ];
      license = licenses.free;
      platforms = platforms.all;
      skip.ci = true;
    };
  };

  westra = fetchwebarchive {
    name = "westra-2020-12-30";
    url = "https://nakarte.me/westraPasses/westra_passes.json";
    timestamp = "20201230113603";
    hash = "sha256-yW3gAc2izsLkjWrz8TgU1F/kYNYJrixEZyIKyv0vGuU=";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = ''
      install -dm755 $out
      cat $downloadedFile | \
        ${jq}/bin/jq -r '.[]|[.latlon[1],.latlon[0],.name]|@csv' > $out/westra_passes.csv
    '';

    meta = with lib; {
      homepage = "https://westra.ru/passes/";
      description = "Mountain passes (Westra)";
      maintainers = [ maintainers.sikmir ];
      license = licenses.free;
      platforms = platforms.all;
    };
  };

  strelki = fetchurl {
    name = "strelki-2022-01-31";
    url = "https://strelki.extremum.org/s/p/47p";
    hash = "sha256-p+KYOaEJCQAwEQSl4VPdxxK6Kt/QLPlRHNbxi/RVrj0=";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = ''
      install -dm755 $out
      cat $downloadedFile | \
        grep "L.marker" | tr ';' '\n' | sed '/^$/d' | \
        sed 's/.*\[\(.*\), \(.*\)\].*bindTooltip(\(.*\), {.*bindPopup(\(.*\)).addTo.*/\2,\1,\3,\4/' | \
        sed 's#href=#href=https://strelki.extremum.org#' | \
        tr \' \" > $out/strelki.csv
    '';

    meta = with lib; {
      homepage = "https://strelki.extremum.org/s/p/47p";
      description = "Стрелки-47";
      maintainers = [ maintainers.sikmir ];
      license = licenses.free;
      platforms = platforms.all;
    };
  };

  nashipohody = fetchurl {
    name = "nashipohody-2020-07-23";
    url = "http://nashipohody.ru/wp-content/plugins/leaflet-maps-marker-pro/leaflet-kml.php?layer=1&name=show";
    sha256 = "1bp0f125yz91x7pridzs4ggvvny98790lb1ddrnwzbwjn1v756c4";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = "install -Dm644 $downloadedFile $out/nashipohody.kml";

    meta = with lib; {
      homepage = "http://nashipohody.ru";
      description = "Карта Достопримечательностей";
      maintainers = [ maintainers.sikmir ];
      license = licenses.free;
      platforms = platforms.all;
    };
  };

  novgorod-roads = fetchymaps {
    name = "novgorod-roads-2013-06-05";
    um = "_WjokOS8OVNds5FVsSPwRN_dXQFBv99B";
    hash = "sha256-cN/iJ7aV4329UU5Qbfwp16K7yCU15ZOKQu8DnBbJE1M=";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = ''
      ${gdal}/bin/ogr2ogr novgorod-roads.geojson $downloadedFile
      install -Dm644 novgorod-roads.geojson -t $out
    '';

    meta = with lib; {
      homepage = "https://yandex.ru/maps/-/CCUER2fZpD";
      description = "Магистральные дороги Северо-Запада Новгородской земли";
      maintainers = [ maintainers.sikmir ];
      license = licenses.free;
      platforms = platforms.all;
      skip.ci = true;
    };
  };
}
