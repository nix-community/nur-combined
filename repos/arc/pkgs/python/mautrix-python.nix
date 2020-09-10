{ lib, fetchFromGitHub, pythonPackages }:

with pythonPackages;

buildPythonPackage rec {
  pname = "mautrix-python";
  version = "0.7.1";
  src = fetchFromGitHub {
    owner = "tulir";
    repo = "mautrix-python";
    rev = "v${version}";
    sha256 = "0pd5hpfjc4habgp6qnyd3icl476552pxgxg3ajn7fv3xl98rbckj";
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
