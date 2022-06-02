{ lib, python3Packages, fetchFromGitHub, cykhash, pyrobuf }:

python3Packages.buildPythonPackage rec {
  pname = "pyrosm";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "HTenkanen";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-/VS8TWSn/UACtRIRX9iaA39ikIzL1pzgNzZntPFYNmw=";
  };

  nativeBuildInputs = with python3Packages; [ cython ];

  propagatedBuildInputs = with python3Packages; [
    python-rapidjson
    geopandas
    pygeos
    cykhash
    pyrobuf
  ];

  doCheck = false;

  checkInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "pyrosm" ];

  meta = with lib; {
    description = "A Python tool to parse OSM data from Protobuf format into GeoDataFrame";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
