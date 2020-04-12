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
  version = "1.5.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0mypfz5k1phn7b2fk362w8zqh2wi3czf58g4zik64n17r8viww40";
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
