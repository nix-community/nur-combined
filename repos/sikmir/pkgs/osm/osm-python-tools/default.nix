{ lib, stdenv, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "osm-python-tools";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "mocnik-science";
    repo = "osm-python-tools";
    rev = "v${version}";
    hash = "sha256-lTDA1Rad9aYI/ymU/0xzdJHmebUGcpVJ0GW7D0Ujdko=";
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
