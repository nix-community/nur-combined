{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, certifi
, crcmod
, pycryptodome
, requests
, six
, xmltodict
}:
buildPythonPackage rec {
  pname = "cos-python-sdk-v5";
  version = "1.9.44";
  pyproject = true;

  src = fetchPypi {
    pname = "cos_python_sdk_v5";
    inherit version;
    hash = "sha256-KrQD87ZO/buaGYStPkOBvX8HVdEGQUiuslJpvXV7Sas=";
  };

  build-system = [ setuptools ];

  dependencies = [
    certifi
    crcmod
    pycryptodome
    requests
    six
    xmltodict
  ];

  # Upstream caps certifi<=2021.10.8 and requests<=2.27.1.
  pythonRelaxDeps = [ "certifi" "requests" ];

  # The test suite talks to real COS endpoints.
  doCheck = false;
  pythonImportsCheck = [ "qcloud_cos" ];

  meta = {
    description = "Tencent Cloud COS (Cloud Object Storage) SDK for Python";
    homepage = "https://github.com/tencentyun/cos-python-sdk-v5";
    license = lib.licenses.mit;
  };
}
