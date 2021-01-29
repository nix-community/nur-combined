{ lib, python3Packages, fetchurl }:

python3Packages.buildPythonApplication rec {
  pname = "phyghtmap";
  version = "2.23";

  src = fetchurl {
    url = "http://katze.tfiu.de/projects/phyghtmap/phyghtmap_${version}.orig.tar.gz";
    sha256 = "04xhqcf4bvgbahzw1vcx4khja0z3xqkd0mvk2z8b0xnmy5rsw3lc";
  };

  propagatedBuildInputs = with python3Packages; [ beautifulsoup4 lxml matplotlib numpy ];

  postInstall = "install -Dm644 docs/phyghtmap.1 -t $out/share/man/man1";

  meta = with lib; {
    description = "Generate OSM contour lines from NASA SRTM data";
    homepage = "http://katze.tfiu.de/projects/phyghtmap";
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
