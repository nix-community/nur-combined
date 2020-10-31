{ lib, fetchFromGitHub, fetchzip, protobuf3_13 ? null, pythonPackages }:

with pythonPackages;

buildPythonPackage rec {
  pname = "hangups";
  version = "0.4.12";

  src = fetchPypi {
    inherit pname version;
    sha256 = "06vhn5mx2h4b1rgwwhqbi1kx1mwddd55ygkc5jfaqpwisbmfv9hs";
  };

  propagatedBuildInputs = [
    (ConfigArgParse.overrideAttrs (old: rec {
      version = "0.11.0";
      src = fetchPypi {
        inherit version;
        inherit (old) pname;
        sha256 = "12dcl0wdsjxgphxadyz9bdzbvlwfaqgvba9s59ghajw4yqiyi2kc";
      };
    }))
    aiohttp
    async-timeout
    appdirs
    readlike
    requests
    reparser
    ((protobuf.overrideAttrs (old: rec {
      version = "3.13.0";
      src = fetchFromGitHub {
        repo = "protobuf";
        owner = "protocolbuffers";
        rev = "v${version}";
        sha256 = "1nqsvi2yfr93kiwlinz8z7c68ilg1j75b2vcpzxzvripxx5h6xhd";
      };
    })).override { protobuf = protobuf3_13; })
    urwid1
    (MechanicalSoup.overrideAttrs (old: rec {
      version = "0.6.0";
      src = fetchzip {
        url = "https://files.pythonhosted.org/packages/50/ae/015244f26e2603b15f796fdd42aa99d20c9a395606900909e119a971fa8e/${old.pname}-${version}.zip";
        sha256 = "1dm6lhka09k9hcmhsxxz53i7kq47lb8fqp345m6hga6bwa28ksir";
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

  meta.broken = pythonPackages.python.isPy2 || protobuf3_13 == null;
}
