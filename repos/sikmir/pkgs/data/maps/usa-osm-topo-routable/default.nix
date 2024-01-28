{ lib, stdenvNoCC, fetchurl, p7zip }:

stdenvNoCC.mkDerivation rec {
  pname = "usa-osm-topo-routable";
  version = "39";

  src = fetchurl {
    url = "https://gmaptool.eu/sites/default/files/download/USA_OSM_Topo_Base_v${version}.7z";
    hash = "sha256-MeXzOWmVRX11NFcFCNRdCn7k4i+ckqmJ4jNl9jVaqqk=";
  };

  nativeBuildInputs = [ p7zip ];

  installPhase = "7z x USA_OSM_Topo_v${version}.7z -o$out";

  meta = with lib; {
    description = "USA OSM Topo Routable";
    homepage = "https://www.gmaptool.eu/en/content/usa-osm-topo-routable";
    license = licenses.cc-by-nc-40;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
