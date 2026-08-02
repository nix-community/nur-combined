{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "cogdumper";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "COGDumper";
    rev = "bfc823fbd54901573a27ce83d7311e01d8d9066c";
    hash = "sha256-+/PFfcb3peFIFh41rXsezgOsgEeti3mdMfTgS5ljOFE=";
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
