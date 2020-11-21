{ lib, fetchurl }:
let
  pname = "gpsmap64";
  version = "5.60";
  filename = "GPSMAP64_WebUpdater__${lib.replaceStrings [ "." ] [ "" ] version}.gcd";
in
fetchurl {
  name = "${pname}-${version}";
  url = "http://gawisp.com/perry/gpsmap62_64_78/${filename}";
  sha256 = "1pb4clvwfc7cnsl4n9nbgf5fq8ni7dysrkv48l2286c6knxa3rwd";
  downloadToTemp = true;
  recursiveHash = true;
  preferLocalBuild = true;
  postFetch = "install -Dm644 $downloadedFile $out/${filename}";

  meta = with lib; {
    homepage = "https://www8.garmin.com/support/download_details.jsp?id=6805";
    description = "GPSMAP 64 (WebUpdater)";
    maintainers = [ maintainers.sikmir ];
    license = licenses.free;
    platforms = platforms.all;
    skip.ci = true;
  };
}
