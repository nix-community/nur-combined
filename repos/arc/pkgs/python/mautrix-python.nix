{ lib, fetchFromGitHub, pythonPackages }:

with pythonPackages;

buildPythonPackage rec {
  pname = "mautrix-python";
  version = "0.8.15";
  src = fetchFromGitHub {
    owner = "tulir";
    repo = "mautrix-python";
    rev = "v${version}";
    sha256 = "0jzkx9zli981s39dbd1v03jwi5pqj356y0w0ybf2pbpp9l9ypmcr";
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

  meta.broken = pythonOlder "3.6";
}
