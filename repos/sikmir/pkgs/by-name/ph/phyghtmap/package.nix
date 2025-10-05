{
  lib,
  stdenv,
  python3Packages,
  fetchurl,
  installShellFiles,
}:

python3Packages.buildPythonApplication rec {
  pname = "phyghtmap";
  version = "2.23";
  pyproject = true;

  src = fetchurl {
    url = "http://katze.tfiu.de/projects/phyghtmap/phyghtmap_${version}.orig.tar.gz";
    hash = "sha256-jA6uc/HVdrDQF3NX0Cbu4wMl4SSd7cA/VOvtRRzDsBM=";
  };

  postPatch = ''
    substituteInPlace phyghtmap/hgt.py --replace-fail "_contour" "contour"
  '';

  build-system = with python3Packages; [ setuptools ];

  nativeBuildInputs = [ installShellFiles ];

  dependencies = with python3Packages; [
    beautifulsoup4
    lxml
    matplotlib
    numpy
  ];

  postInstall = "installManPage docs/phyghtmap.1";

  meta = {
    description = "Generate OSM contour lines from NASA SRTM data";
    homepage = "http://katze.tfiu.de/projects/phyghtmap";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
