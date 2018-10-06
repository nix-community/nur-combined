{ stdenv, buildPythonPackage, fetchPypi
, cryptography
, flake8, nose, mock, coverage
}:
buildPythonPackage rec {
  pname = "http_ece";
  version = "1.0.5";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1k06843n5q1rp3wh8qx1akl9lmcsvl2p1qxi9a9w581i1ija0c9g";
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

  meta = with stdenv.lib; {
    description = "Encryped Content-Encoding for HTTP";
    homepage = https://github.com/web-push-libs/encrypted-content-encoding;
    license = licenses.mit;
  };
}
