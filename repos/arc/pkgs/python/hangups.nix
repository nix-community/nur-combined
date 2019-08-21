{ lib, fetchFromGitHub, fetchzip, pythonPackages }:

with pythonPackages;

buildPythonPackage rec {
  pname = "hangups";
  version = "0.4.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1jw4i58cd4j1ymsnhv9224xsi26w8y0qrj6z4nw50dnbl45b6aaa";
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
    (protobuf.overrideAttrs (old: rec {
      version = "3.6.1.2";
      src = fetchFromGitHub {
        repo = "protobuf";
        owner = "protocolbuffers";
        rev = "v${version}";
        sha256 = "16ppd6xz840d5sxii5y1h3y3i0j21hzcfvb9g950w3kj2qx7skqb";
      };
    }))
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

  meta.broken = lib.isNixpkgsStable || pythonPackages.python.isPy2;
}
