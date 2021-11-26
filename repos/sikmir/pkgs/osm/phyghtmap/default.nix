{ lib, stdenv, python3Packages, fetchurl, installShellFiles }:

python3Packages.buildPythonApplication rec {
  pname = "phyghtmap";
  version = "2.23";

  src = fetchurl {
    url = "http://katze.tfiu.de/projects/phyghtmap/phyghtmap_${version}.orig.tar.gz";
    hash = "sha256-jA6uc/HVdrDQF3NX0Cbu4wMl4SSd7cA/VOvtRRzDsBM=";
  };

  nativeBuildInputs = [ installShellFiles ];

  propagatedBuildInputs = with python3Packages; [ beautifulsoup4 lxml matplotlib numpy ];

  postInstall = "installManPage docs/phyghtmap.1";

  meta = with lib; {
    description = "Generate OSM contour lines from NASA SRTM data";
    homepage = "http://katze.tfiu.de/projects/phyghtmap";
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.sikmir ];
  };
}
