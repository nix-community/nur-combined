{ stdenv
, buildPythonPackage
, fetchPypi
, requests
, dateutil
, pytz
, decorator
, http_ece
, cryptography
, pytestcov
, pytest-mock
, vcrpy
, pytestrunner
, python_magic
, blurhash
}:

buildPythonPackage rec {
  pname = "Mastodon.py";
  version = "1.5.1";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1vikvkzcij2gd730cssigxi38vlmzqmwdy58r3y2cwsxifnxpz9a";
  };
  propagatedBuildInputs = [
    requests
    dateutil
    pytz
    decorator
    http_ece
    cryptography
    python_magic
    blurhash
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
    homepage = "https://github.com/halcy/Mastodon.py";
    license = licenses.mit;
  };
}
