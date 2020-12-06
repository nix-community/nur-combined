{ lib, fetchurl, unzip }:
let
  pname = "opentopomap";
  version = "2020-12-04";
in
fetchurl {
  name = "${pname}-${version}";
  url = "http://garmin.opentopomap.org/data/russia-european-part/russia-european-part_garmin.zip";
  sha256 = "03qr10fs4h668v2r92scwmr0a76zacp962rgny4xn9dfhax8bfg7";
  downloadToTemp = true;
  recursiveHash = true;
  preferLocalBuild = true;
  postFetch = "${unzip}/bin/unzip $downloadedFile -d $out";

  meta = with lib; {
    description = "OpenTopoMap Garmin Edition";
    homepage = "http://garmin.opentopomap.org/";
    license = licenses.cc-by-nc-sa-40;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
