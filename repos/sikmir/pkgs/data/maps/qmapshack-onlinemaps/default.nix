{ lib, fetchwebarchive, unzip }:

fetchwebarchive {
  name = "qmapshack-onlinemaps-2021-01-26";
  url = "http://www.mtb-touring.net/wp-content/uploads/Onlinemaps.zip";
  timestamp = "20210507005409";
  hash = "sha256-WD2t7ZiweHMy2Mx1SE2oFWlgWk33s5JBybdNKartNnI=";
  downloadToTemp = true;
  recursiveHash = true;
  postFetch = ''
    ${unzip}/bin/unzip $downloadedFile -d $out
  '';

  meta = with lib; {
    description = "Onlinekarten einbinden";
    homepage = "http://www.mtb-touring.net/qms/onlinekarten-einbinden/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
