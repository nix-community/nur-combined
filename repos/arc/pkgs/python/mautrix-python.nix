{ lib, fetchFromGitHub, pythonPackages }:

with pythonPackages;

buildPythonPackage rec {
  pname = "mautrix-python";
  version = "0.4.0.dev46";
  src = fetchFromGitHub {
    owner = "tulir";
    repo = "mautrix-python";
    rev = "7866b68b2b31bc7b0108a38f788d2915bf23174e";
    sha256 = "1jd1dfz47kxxkmknwr1b58d8pyipzy729hmj6gzxw6kp3jngpg74";
  };

  propagatedBuildInputs = [
    aiohttp
    attrs
    lxml
    ruamel_yaml
    CommonMark
    sqlalchemy
  ];

  checkInputs = [
    pytest
    pytestrunner
    pytest-mock
    pytest-asyncio
  ];

  meta.broken = lib.versionOlder python.version "3.6";
}
