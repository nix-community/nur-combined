{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  cykhash,
  pyrobuf,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyrosm";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "HTenkanen";
    repo = "pyrosm";
    rev = "v${version}";
    hash = "sha256-eX6lOkprU/RkSz2+dGlRtdQQsI+m9GZyN/VfcIix79k=";
  };

  nativeBuildInputs = with python3Packages; [ cython ];

  propagatedBuildInputs = with python3Packages; [
    python-rapidjson
    geopandas
    shapely
    cykhash
    pyrobuf
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "pyrosm" ];

  meta = with lib; {
    description = "A Python tool to parse OSM data from Protobuf format into GeoDataFrame";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
