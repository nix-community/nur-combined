{ lib, fetchwebarchive, unzip }:

fetchwebarchive {
  name = "qmapshack-onlinemaps-2021-05-21";
  url = "http://www.mtb-touring.net/wp-content/uploads/Onlinemaps.zip";
  timestamp = "20210731232714";
  hash = "sha256-E0YCofyxECtXqzBG++85L2vCQy059MMH129PpL/e/wk=";
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
