{ lib, fetchFromGitHub, pythonPackages }:

with pythonPackages;

buildPythonPackage rec {
  pname = "mautrix-python";
  version = "0.4.0.dev72";
  src = fetchFromGitHub {
    owner = "tulir";
    repo = "mautrix-python";
    rev = "3845a707fa17006c894a093387a912e00187a335";
    sha256 = "0d2nw9vk4xx3gcpjcc6qkm5ynlq7d602lqzsx3fn8405msfx2hv0";
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
