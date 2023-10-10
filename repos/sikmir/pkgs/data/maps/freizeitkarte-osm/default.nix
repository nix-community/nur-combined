{ lib, fetchurl, unzip, country ? "FIN", lang ? "en" }:
let
  pname = "freizeitkarte-osm";
  version = "2020-09-09";
in
fetchurl {
  name = "${pname}-${version}";
  url = "http://download.freizeitkarte-osm.de/garmin/latest/${country}_${lang}_gmapsupp.img.zip";
  hash = "sha256-PKcO9m163R8a+rgFS2guh62iX2xHjyfL5uNODbURTCE=";
  downloadToTemp = true;
  recursiveHash = true;
  preferLocalBuild = true;
  postFetch = "${unzip}/bin/unzip $downloadedFile -d $out";

  meta = with lib; {
    description = "Freizeitkarte map with DEM (Digital Elevation Model) and hillshading";
    homepage = "https://freizeitkarte-osm.de/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
