{ lib, fetchurl, unzip, country ? "RUS" }:
let
  pname = "gadm-" + country;
  version = "3.6";
in
fetchurl {
  name = "${pname}-${version}";
  url = "https://biogeo.ucdavis.edu/data/gadm${version}/gpkg/gadm${lib.replaceStrings [ "." ] [ "" ] version}_${country}_gpkg.zip";
  hash = {
    RUS = "sha256-buGdrpsbgcYlaJSxOOeHLXQLEmAHMfy7/eDf4ZpXs/4=";
    FIN = "sha256-avDQrL5OWix/13MbfQdoUd/dmRPmcCnMt0ohmUqlkGQ=";
    EST = "sha256-+9vErTSvu52eG03ohnRcC9hk9d10Unpyji8WVbfuaq4=";
  }.${country};
  downloadToTemp = true;
  recursiveHash = true;
  preferLocalBuild = true;
  postFetch = "${unzip}/bin/unzip $downloadedFile -d $out";

  meta = with lib; {
    description = "GADM data";
    homepage = "https://gadm.org";
    changelog = "https://gadm.org/changelog.html";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
