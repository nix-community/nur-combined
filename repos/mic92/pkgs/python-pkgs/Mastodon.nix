{ stdenv, buildPythonPackage, fetchPypi
, requests, dateutil, pytz, decorator, http_ece, cryptography
, pytestcov, pytest-mock, vcrpy, pytestrunner
}:

buildPythonPackage rec {
  pname = "Mastodon.py";
  version = "1.3.1";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1xih3wq47ki5wxm04v4haqnxc38hvnkx28yrmpyr02klw8s0y01z";
  };
  propagatedBuildInputs = [
    requests dateutil pytz decorator http_ece cryptography
  ];
  buildInputs = [
    pytestrunner
  ];

  doCheck = false;
  # not all deps packaged yet
  checkInputs = [
    pytestcov
    pytest-mock
    vcrpy
  ];

  meta = with stdenv.lib; {
    description = "Python wrapper for the Mastodon API";
    homepage = https://github.com/halcy/Mastodon.py;
    license = licenses.mit;
  };
}
