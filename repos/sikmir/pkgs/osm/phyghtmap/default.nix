{ lib, python3Packages, fetchurl }:

python3Packages.buildPythonApplication rec {
  pname = "phyghtmap";
  version = "2.21";

  src = fetchurl {
    url = "http://katze.tfiu.de/projects/phyghtmap/phyghtmap_${version}.orig.tar.gz";
    sha256 = "08dsqsq6cxncr2gahd672kcvhfn0pr2mvspiim7j5v0vvgrjv2p8";
  };

  propagatedBuildInputs = with python3Packages; [ beautifulsoup4 lxml matplotlib numpy ];

  postInstall = "install -Dm644 docs/phyghtmap.1 -t $out/share/man/man1";

  meta = with lib; {
    description = "Generate OSM contour lines from NASA SRTM data";
    homepage = "http://katze.tfiu.de/projects/phyghtmap";
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
