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
    tag = "v${version}";
    hash = "sha256-eX6lOkprU/RkSz2+dGlRtdQQsI+m9GZyN/VfcIix79k=";
  };

  nativeBuildInputs = with python3Packages; [ cython ];

  dependencies = with python3Packages; [
    python-rapidjson
    geopandas
    shapely
    cykhash
    pyrobuf
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "pyrosm" ];

  meta = {
    description = "A Python tool to parse OSM data from Protobuf format into GeoDataFrame";
    homepage = "https://github.com/HTenkanen/pyrosm";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
