{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "opentopomap";
  version = "2020-05-15";

  src = fetchurl {
    url = "http://garmin.opentopomap.org/data/russia-european-part/russia-european-part_garmin.zip";
    sha256 = "130h349ja358qmdszq8lhfi0flskhrjcf65z1f9v4vmhf67wj719";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = "unzip $src";

  dontConfigure = true;
  dontBuild = true;

  preferLocalBuild = true;

  installPhase = ''
    install -Dm644 *.img -t "$out/share/qmapshack/Maps"
  '';

  meta = with stdenv.lib; {
    description = "OpenTopoMap Garmin Edition";
    homepage = "http://garmin.opentopomap.org/";
    license = licenses.cc-by-nc-sa-40;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
