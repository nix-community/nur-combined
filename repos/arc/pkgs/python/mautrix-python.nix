{ lib, fetchFromGitHub, pythonPackages }:

with pythonPackages;

buildPythonPackage rec {
  pname = "mautrix-python";
  version = "0.4.0.dev77";
  src = fetchFromGitHub {
    owner = "tulir";
    repo = "mautrix-python";
    rev = "4bcea1732a0f836773d15b9c10f7d999001ec658";
    sha256 = "0qgdbwyg26y6hi06i8r70s285bvkdil15va7fx8bc3n87g464kkn";
  };

  propagatedBuildInputs = [
    aiohttp
    attrs
    lxml
    ruamel_yaml
    CommonMark
    sqlalchemy
  ];

  doCheck = false;
  checkInputs = [
    pytest
    pytestrunner
    pytest-mock
    pytest-asyncio
  ];

  meta.broken = lib.versionOlder python.version "3.6";
}
