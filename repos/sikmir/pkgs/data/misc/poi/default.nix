{ lib, fetchurl, fetchymaps, gzip, jq, gdal }:

{
  geocachingSu = fetchurl {
    name = "geocaching_su-2020-12-16";
    url = "https://nakarte.me/geocachingSu/geocaching_su2.json";
    sha256 = "1ahq3q3c1s9r7xd2mlnws98v3p1my7lilsq0hdccinqhmzsi798d";
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
    name = "laavut-2020-11-16";
    url = "http://laavu.org/lataa.php?paikkakunta=kaikki";
    sha256 = "11b8ipd6whdiwb1vx6580b9syjgrcf573kr80zpwl5nx1k3rxm95";
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
    name = "westra-2020-12-16";
    url = "https://nakarte.me/westraPasses/westra_passes.json";
    sha256 = "1k8snxg95jfcmjqzx81s0r751pmx5pakq5kd2lq01zrvss725mpz";
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
    name = "strelki-2020-11-25";
    url = "https://strelki.extremum.org/s/p/47p";
    sha256 = "0i1b7pvmxvlbp76nrjaghd0fyv1lj6z8wy8hbvzcjclh1d3fm5xa";
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

  novgorod-roads = fetchymaps {
    name = "novgorod-roads-2013-06-05";
    um = "_WjokOS8OVNds5FVsSPwRN_dXQFBv99B";
    sha256 = "1hyilj5h24rdfnhmks3zk4z76zi3y6mn5qc47w9wd2yv2vzjdp53";
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
