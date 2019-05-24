{ buildApp }:
buildApp rec {
  appName = "gpxpod";
  version = "3.0.3";
  url = "https://gitlab.com/eneiluj/gpxpod-oc/wikis/uploads/34af9435d7a2cd8fa915b84f0dda0724/${appName}-${version}.tar.gz";
  sha256 = "0v30j5b4ki6nbxqdmnlkrgl1lpg2x2nir9gik6rfj0c3jhmb5mch";
  otherConfig = {
    mimetypealiases = {
      "application/gpx+xml" = "gpx";
    };
    mimetypemapping = {
      "gpx" = ["application/gpx+xml"];
    };
  };
}
