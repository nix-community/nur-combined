{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
, requests
}:

let
  pname = "grobid-client-python";
  version = "unstable-2023-02-07";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "kermitt2";
    repo = "grobid_client_python";
    rev = "28d426a1258e74712b2aef9e1ecaef903af9b1c0";
    hash = "sha256-oxMri55tz+2uibp/92WgZhBihgvj6L6amYuIWDXlvsc=";
  };

  propagatedBuildInputs = [
    requests
  ];

  checkInputs = [
    # pytestCheckHook
  ];

  pythonImportsCheck = [
    "grobid_client"
  ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.asl20;
    description = "Python client for GROBID Web services";
    homepage = "https://github.com/kermitt2/grobid_client_python";
    platforms = lib.platforms.unix;
  };
}

