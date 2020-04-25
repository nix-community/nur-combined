{ lib, fetchurl, gzip, jq }:

{
  geocachingSu = fetchurl {
    name = "geocaching_su-2020-04-25";
    url = "https://nakarte.me/geocachingSu/geocaching_su2.json";
    sha256 = "sha256-suexI3GL8QWAaxonKQwi0qcPbvUF2GBjiRVnacoP0lk=";
    downloadToTemp = true;
    recursiveHash = true;
    preferLocalBuild = true;
    postFetch = ''
      install -dm755 $out/share/gpxsee/POI
      cat $downloadedFile | \
        ${gzip}/bin/gzip -d | \
        ${jq}/bin/jq -r '.[]|[.[3],.[2],.[0]]|@csv' > $out/share/gpxsee/POI/geocaching.su.csv
    '';

    meta = with lib; {
      homepage = "https://geocaching.su/";
      description = "Geocaches";
      maintainers = with maintainers; [ sikmir ];
      license = licenses.free;
      platforms = platforms.all;
      skip.ci = true;
    };
  };

  laavut = fetchurl {
    name = "laavut-2020-04-24";
    url = "http://www.laavu.org/lataa.php?paikkakunta=kaikki";
    sha256 = "sha256-wFWsvLh43/NY3CeP4bo5egTT3jonrltjKLlZPfUlUlI=";
    downloadToTemp = true;
    recursiveHash = true;
    preferLocalBuild = true;
    postFetch = ''
      install -Dm644 $downloadedFile $out/share/gpxsee/POI/Laavut-kodat.gpx
    '';

    meta = with lib; {
      homepage = "http://www.laavu.org/";
      description = "Laavut ja kodat kartalla";
      maintainers = with maintainers; [ sikmir ];
      license = licenses.free;
      platforms = platforms.all;
      skip.ci = true;
    };
  };

  autiotuvat = fetchurl {
    name = "autiotuvat-2020-01-13";
    url = "http://www.laavu.org/autiotuvat/lataa.php?paikkakunta=kaikki";
    sha256 = "sha256-HxTZiWMyxL3KanU8EOJzrEV4mFBpJVKorpVafXupZAs=";
    downloadToTemp = true;
    recursiveHash = true;
    preferLocalBuild = true;
    postFetch = ''
      install -Dm644 $downloadedFile $out/share/gpxsee/POI/Autiotuvat.gpx
    '';

    meta = with lib; {
      homepage = "http://www.laavu.org/autiotuvat/";
      description = "Autiotuvat kartalla";
      maintainers = with maintainers; [ sikmir ];
      license = licenses.free;
      platforms = platforms.all;
      skip.ci = true;
    };
  };
}
