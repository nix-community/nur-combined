{ lib, fetchurl, gzip, jq }:

{
  geocachingSu = fetchurl {
    name = "geocaching_su-2020-10-24";
    url = "https://nakarte.me/geocachingSu/geocaching_su2.json";
    sha256 = "17mc1yisf7dshld75bvr5sir3dylps01a9p0bk5ks9r8dba9q77p";
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
    name = "laavut-2020-10-18";
    url = "http://www.laavu.org/lataa.php?paikkakunta=kaikki";
    sha256 = "0cvsfxlnibx1s9fh6v0kk77n0yg497znyiwj1n4ih77w1q8jxpw0";
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
    name = "autiotuvat-2020-09-29";
    url = "http://www.laavu.org/autiotuvat/lataa.php?paikkakunta=kaikki";
    sha256 = "1my36s3a20il2bziylg3f2bw0r43axsnqq6zr9wv5513h6z4axqc";
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
    name = "westra-2020-10-12";
    url = "https://nakarte.me/westraPasses/westra_passes.json";
    sha256 = "1s8sg3n74kppi8hylpm2w257ahbbsrz8sah2mqzc75d94xsda6jz";
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
    name = "strelki-2020-10-12";
    url = "https://strelki.extremum.org/s/p/47p";
    sha256 = "0bdq6xh50rlpcg2bzvbcf98ay814hm4569zjnw3pi7mqy09pydiy";
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
