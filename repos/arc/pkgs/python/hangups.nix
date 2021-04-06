{ lib, pythonPackages }:

with pythonPackages;

buildPythonPackage rec {
  pname = "hangups";
  version = "0.4.13";

  src = fetchPypi {
    inherit pname version;
    sha256 = "015g635vnrxk5lf9n80rdcmh6chv8kmla1k2j7m1iijijs519ngn";
  };

  propagatedBuildInputs = [
    ConfigArgParse
    aiohttp
    async-timeout
    appdirs
    readlike
    requests
    reparser
    protobuf
    urwid
    (MechanicalSoup.overrideAttrs (old: rec {
      version = "0.12.0";
      src = fetchPypi {
        inherit version;
        inherit (old) pname;
        sha256 = "1g976rk79apz6rc338zq3ml2yps8hb88nyw3a698d0brm4khd9ir";
      };
    }))
  ];

  checkInputs = [
    httpretty
    pytest
    pytestrunner
    pytest-mock
    pytest-asyncio
  ];

  meta.broken = lib.versionOlder python.version "3.6" || lib.isNixpkgsStable;
}
