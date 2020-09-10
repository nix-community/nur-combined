{ lib, fetchFromGitHub, fetchzip, protobuf3_10 ? null, pythonPackages }:

with pythonPackages;

buildPythonPackage rec {
  pname = "hangups";
  version = "0.4.11";

  src = fetchPypi {
    inherit pname version;
    sha256 = "165lravvlsgkv6pp3vgg785ihycvs43qzqxw2d2yygrc6pbhqlyv";
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
      version = "3.10.0";
      src = fetchFromGitHub {
        repo = "protobuf";
        owner = "protocolbuffers";
        rev = "v${version}";
        sha256 = "0cjwfm9v2gv6skzrq4m7w28810p2h3m1jj4kw6df3x8vvg7q842c";
      };
    })).override { protobuf = protobuf3_10; })
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

  meta.broken = pythonPackages.python.isPy2 || protobuf3_10 == null;
}
