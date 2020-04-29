{ stdenv, fetchurl, unzip, country ? "FIN", lang ? "en" }:

stdenv.mkDerivation rec {
  pname = "freizeitkarte-osm";
  version = "2020-04-06";

  src = fetchurl {
    url = "http://download.freizeitkarte-osm.de/garmin/latest/${country}_${lang}_gmapsupp.img.zip";
    sha256 = "0wnfxb02n7niaa4ma6w6gxkfqfg5w7achkq1l5cyjpnhgjzlsw94";
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
    description = "Freizeitkarte map with DEM (Digital Elevation Model) and hillshading";
    homepage = "https://freizeitkarte-osm.de/";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
