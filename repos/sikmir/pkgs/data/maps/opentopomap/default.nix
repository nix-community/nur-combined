{ stdenvNoCC, fetchurl, unzip }:

stdenvNoCC.mkDerivation {
  pname = "opentopomap";
  version = "2020-08-28";

  src = fetchurl {
    url = "http://garmin.opentopomap.org/data/russia-european-part/russia-european-part_garmin.zip";
    sha256 = "130h349ja358qmdszq8lhfi0flskhrjcf65z1f9v4vmhf67wj719";
  };

  unpackPhase = "${unzip}/bin/unzip $src";

  dontConfigure = true;
  dontBuild = true;

  preferLocalBuild = true;

  installPhase = "install -Dm644 *.img -t $out";

  meta = with stdenvNoCC.lib; {
    description = "OpenTopoMap Garmin Edition";
    homepage = "http://garmin.opentopomap.org/";
    license = licenses.cc-by-nc-sa-40;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
