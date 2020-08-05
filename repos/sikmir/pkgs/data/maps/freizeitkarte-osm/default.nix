{ stdenv, fetchurl, unzip, country ? "FIN", lang ? "en" }:

stdenv.mkDerivation {
  pname = "freizeitkarte-osm";
  version = "2020-06-26";

  src = fetchurl {
    url = "http://download.freizeitkarte-osm.de/garmin/latest/${country}_${lang}_gmapsupp.img.zip";
    sha256 = "0nbp7nw7yi8d4wd19ll33h0wbb7zmz6r4lnxcqzqlnkbvspz8qyb";
  };

  unpackPhase = "${unzip}/bin/unzip $src";

  dontConfigure = true;
  dontBuild = true;

  preferLocalBuild = true;

  installPhase = ''
    install -Dm644 *.img -t $out/share/qmapshack/Maps
  '';

  meta = with stdenv.lib; {
    description = "Freizeitkarte map with DEM (Digital Elevation Model) and hillshading";
    homepage = "https://freizeitkarte-osm.de/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
