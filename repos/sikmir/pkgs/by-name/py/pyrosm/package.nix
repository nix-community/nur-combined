{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  cykhash,
  pyrobuf,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyrosm";
  version = "0.28.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "HTenkanen";
    repo = "pyrosm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XjTpqqWmq/tMmy80u4LFvlaZ0H64pSlbW0WN/JK2eaQ=";
  };

  build-system = with python3Packages; [
    setuptools
    cython
  ];

  dependencies = with python3Packages; [
    python-rapidjson
    geopandas
    shapely
    cykhash
    protobuf
    pyarrow
    pyrobuf
    tqdm
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
})
