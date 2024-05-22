{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pystac";
  version = "1.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "stac-utils";
    repo = "pystac";
    rev = "v${version}";
    hash = "sha256-LbHeEA/F96nVejsNVMR/zrIgIyrBxHiinHcLzk68uA0=";
  };

  build-system = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [ python-dateutil ];

  nativeCheckInputs = with python3Packages; [
    html5lib
    jsonschema
    pytestCheckHook
    pytest-cov
    pytest-mock
    pytest-recording
    requests-mock
  ];

  pythonImportsCheck = [ "pystac" ];

  meta = with lib; {
    description = "Python library for working with any SpatioTemporal Asset Catalog (STAC)";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
