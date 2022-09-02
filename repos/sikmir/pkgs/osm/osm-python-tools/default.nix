{ lib, stdenv, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "osm-python-tools";
  version = "2021-09-16";

  src = fetchFromGitHub {
    owner = "mocnik-science";
    repo = "osm-python-tools";
    rev = "4ae053f65c1639bb8f0fe961c94594d31eada952";
    hash = "sha256-3Eru0pXJtKDBs3mSpW+Z+r8d2XLmuMRTEhA4IMPrPpQ=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "'pytest" "#'pytest" \
  '';

  propagatedBuildInputs = with python3Packages; [
    beautifulsoup4
    geojson
    lxml
    matplotlib
    numpy
    pandas
    ujson
    xarray
  ];

  doCheck = false;

  pythonImportsCheck = [
    "OSMPythonTools.api"
    "OSMPythonTools.data"
    "OSMPythonTools.nominatim"
    "OSMPythonTools.overpass"
  ];

  meta = with lib; {
    description = "A library to access OpenStreetMap related services";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
  };
}
