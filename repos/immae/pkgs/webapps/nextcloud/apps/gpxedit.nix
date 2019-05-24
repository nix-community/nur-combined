{ buildApp }:
buildApp rec {
  appName = "gpxedit";
  version = "0.0.11";
  url = "https://gitlab.com/eneiluj/gpxedit-oc/wikis/uploads/18058077d0170256c3f4c9201443d09d/${appName}-${version}.tar.gz";
  sha256 = "1ww32jysjnwxrn8r9fjdfhbfqnzgaakn08m64wcmavx29dd42y6m";
  otherConfig = {
    mimetypealiases = {
      "application/gpx+xml" = "gpx";
    };
    mimetypemapping = {
      "gpx" = ["application/gpx+xml"];
    };
  };
}
