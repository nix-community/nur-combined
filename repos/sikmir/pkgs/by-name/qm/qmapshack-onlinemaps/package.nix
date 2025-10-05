{
  lib,
  fetchwebarchive,
  unzip,
}:

fetchwebarchive {
  name = "qmapshack-onlinemaps-2024-07-29";
  url = "http://www.mtb-touring.net/wp-content/uploads/Onlinemaps.zip";
  timestamp = "20250116120355";
  hash = "sha256-mgeskUSjnQJZAp9LXyXXGFoAUEXmhqy4wRYquVUygbc=";
  downloadToTemp = true;
  recursiveHash = true;
  postFetch = ''
    ${unzip}/bin/unzip $downloadedFile -d $out
  '';

  meta = {
    description = "Onlinekarten einbinden";
    homepage = "http://www.mtb-touring.net/qms/onlinekarten-einbinden/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
