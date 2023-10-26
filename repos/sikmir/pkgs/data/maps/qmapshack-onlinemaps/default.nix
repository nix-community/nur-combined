{ lib, fetchwebarchive, unzip }:

fetchwebarchive {
  name = "qmapshack-onlinemaps-2022-09-02";
  url = "http://www.mtb-touring.net/wp-content/uploads/Onlinemaps.zip";
  timestamp = "20231026090331";
  hash = "sha256-5xXyaWhUwOZPGb+unYh4A0Hzznk2nRPHtIxdiiQHlHY=";
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
