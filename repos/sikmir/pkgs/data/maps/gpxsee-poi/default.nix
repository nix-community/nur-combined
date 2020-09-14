{ lib, fetchurl, gzip, jq }:

{
  geocachingSu = fetchurl {
    name = "geocaching_su-2020-09-07";
    url = "https://nakarte.me/geocachingSu/geocaching_su2.json";
    sha256 = "1v93vdvxbarqbd4hy6kig0y9h58q1z55zzwf2v7pc1fi6af1carx";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = ''
      install -dm755 $out
      cat $downloadedFile | \
        ${gzip}/bin/gzip -d | \
        ${jq}/bin/jq -r '.[]|[.[3],.[2],.[0]]|@csv' > $out/geocaching.su.csv
    '';

    meta = with lib; {
      homepage = "https://geocaching.su/";
      description = "Geocaches";
      maintainers = [ maintainers.sikmir ];
      license = licenses.free;
      platforms = platforms.all;
      skip.ci = true;
    };
  };

  laavut = fetchurl {
    name = "laavut-2020-09-02";
    url = "http://www.laavu.org/lataa.php?paikkakunta=kaikki";
    sha256 = "1jlff8qdibhqcppwx6x2j9vcbn1gm6395z885r1awjawc81zwrf3";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = "install -Dm644 $downloadedFile $out/Laavut-kodat.gpx";

    meta = with lib; {
      homepage = "http://www.laavu.org/";
      description = "Laavut ja kodat kartalla";
      maintainers = [ maintainers.sikmir ];
      license = licenses.free;
      platforms = platforms.all;
      skip.ci = true;
    };
  };

  autiotuvat = fetchurl {
    name = "autiotuvat-2020-01-13";
    url = "http://www.laavu.org/autiotuvat/lataa.php?paikkakunta=kaikki";
    sha256 = "13dpdqp3vs33q05w9ii1ygd5ijs1bmqghzzylabkykc247x3n1bv";
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

  westra = fetchurl {
    name = "westra-2020-09-02";
    url = "https://nakarte.me/westraPasses/westra_passes.json";
    sha256 = "1q9fn7jrbrpn30hwagkq3yva81v8b6zvhkzjngqvkr08zkarh6bm";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = ''
      install -dm755 $out
      cat $downloadedFile | \
        ${gzip}/bin/gzip -d | \
        ${jq}/bin/jq -r '.[]|[.latlon[1],.latlon[0],.name]|@csv' > $out/westra_passes.csv
    '';

    meta = with lib; {
      homepage = "https://westra.ru/passes/";
      description = "Mountain passes (Westra)";
      maintainers = [ maintainers.sikmir ];
      license = licenses.free;
      platforms = platforms.all;
      skip.ci = true;
    };
  };

  strelki = fetchurl {
    name = "strelki-2020-07-10";
    url = "https://strelki.extremum.org/s/p/47p";
    sha256 = "1px8q8ka5vavalz8kbai8n274469prwif00ymfqf7415g8mhwi24";
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
      skip.ci = true;
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
      skip.ci = true;
    };
  };
}
