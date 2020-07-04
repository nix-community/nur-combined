{ lib
, buildPythonPackage
, fetchFromGitHub
, git
, attrs
, future
, aiohttp
, aiofiles
, h11
, h2
, Logbook
, jsonschema
, unpaddedbase64
, pycryptodome
, python-olm
, peewee
, cachetools
, atomicwrites
}:

buildPythonPackage rec {
  pname = "matrix-nio";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "matrix-nio";
    rev = version;
    sha256 = "1jy0jzwqp7khpzy4qpjrnsryawp4lqd0k5pfdangcjaa3aqzgh5x";
  };

  nativeBuildInputs = [
    git
  ];

  propagatedBuildInputs = [
    attrs
    future
    aiohttp
    aiofiles
    h11
    h2
    Logbook
    jsonschema
    unpaddedbase64
    pycryptodome
    python-olm
    peewee
    cachetools
    atomicwrites
  ];

  doCheck = false;

  meta = with lib; {
    description = "A Python Matrix client library, designed according to sans I/O principles";
    homepage = "https://github.com/poljar/matrix-nio";
    license = licenses.isc;
    maintainers = with maintainers; [ tilpner emily symphorien ];
  };
}
