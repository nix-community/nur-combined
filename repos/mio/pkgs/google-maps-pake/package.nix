{
  lib,
  fetchurl,
  makePakeApp,
}:

makePakeApp {
  pname = "google-maps";
  appName = "Google Maps";
  url = "https://www.google.com/maps";
  icon = fetchurl {
    name = "google-maps-icon.png";
    url = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Google_Maps_icon_%282020%29.svg/1280px-Google_Maps_icon_%282020%29.svg.png";
    hash = "sha256-HVY6iEISjbPa5BKPq4e9bSHPp8D9jCcbFL3iGtf2agw=";
  };
  meta = {
    description = "Desktop application for Google Maps (packaged via Pake)";
    homepage = "https://www.google.com/maps";
    license = lib.licenses.unfree;
  };
}
