{ lib, fetchurl, unzip, country ? "RUS" }:
let
  pname = "gadm-" + country;
  version = "3.6";
in
fetchurl {
  name = "${pname}-${version}";
  url = "https://biogeo.ucdavis.edu/data/gadm${version}/gpkg/gadm${lib.replaceStrings [ "." ] [ "" ] version}_${country}_gpkg.zip";
  sha256 = {
    RUS = "1zmkaydf3pz0znxzqc87c090nx1dhzkkiccld0jwd08vkfp9vqbf";
    FIN = "0r4hlm59j8aanz62jw762fcxvpsid03ps6vksxzjqnjfpsnd1w3a";
    EST = "1bkaxsvma5igirr7llklvpsn9n0bbis8ds2d3fg9vfxg6jnw9nzv";
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
