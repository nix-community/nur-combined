{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "cogdumper";
  version = "0.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "COGDumper";
    rev = "89a5f05fc0ed88c36f44e42dfe8d48e4c4ff389b";
    hash = "sha256-gLBBGP2AMKP8biSbMtrxGs7vLDXbP+Y6Ct82FiNdNjs=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    boto3
    click
    requests
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Dumps tiles out of a cloud optimized geotiff";
    homepage = "https://github.com/mapbox/COGDumper";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
