{ lib, fetchurl, unzip, country ? "FIN", lang ? "en" }:
let
  pname = "freizeitkarte-osm";
  version = "2020-09-09";
in
fetchurl {
  name = "${pname}-${version}";
  url = "http://download.freizeitkarte-osm.de/garmin/latest/${country}_${lang}_gmapsupp.img.zip";
  sha256 = "09g28v8vrw98kskpf8w8cgdzz7lp6bp6zb6xyz7r9b4ndiyzbip7";
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
