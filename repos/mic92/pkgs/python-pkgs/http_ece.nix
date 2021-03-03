{ lib
, buildPythonPackage
, fetchPypi
, cryptography
, flake8
, nose
, mock
, coverage
}:
buildPythonPackage rec {
  pname = "http_ece";
  version = "1.1.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1y5ln09ji4dwpzhxr77cggk02kghq7lql60a6969a5n2lwpvqblk";
  };
  propagatedBuildInputs = [
    cryptography
  ];
  checkInputs = [
    flake8
    nose
    mock
    coverage
  ];

  meta = with lib; {
    description = "Encryped Content-Encoding for HTTP";
    homepage = "https://github.com/web-push-libs/encrypted-content-encoding";
    license = licenses.mit;
  };
}
