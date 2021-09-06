{ lib, stdenv, fetchFromGitHub, fetchpatch, pythonPackages, adafruit-dht ? pythonPackages.adafruit-dht }:

with pythonPackages;

buildPythonApplication rec {
  pname = "dht22_exporter";
  version = "2021-06-01";

  src = fetchFromGitHub {
    owner = "clintjedwards";
    repo = pname;
    rev = "94145b4079ced11205c6f1e5dae9726c1f8d4c33";
    sha256 = "01z53znai7za8c2kbihmmbzy3lgjzdxhm03z7f3gwydh7wyx5b0x";
  };

  patches = [
    (fetchpatch {
      name = "provide-a-setup-py.patch";
      url = "https://patch-diff.githubusercontent.com/raw/clintjedwards/dht22_exporter/pull/5.patch";
      sha256 = "18y5qdkjc9krjjvd77nc3yw6mlghjfpzsidf2x3yxflxxbhyvcf5";
    })
    (fetchpatch {
      name = "provide-an-address-argument.patch";
      url = "https://patch-diff.githubusercontent.com/raw/clintjedwards/dht22_exporter/pull/6.patch";
      sha256 = "13bsmagacnirf0fh311ap3bxylvsb39q7dwyzab33awk1hn8k467";
    })
  ];

  propagatedBuildInputs = [
    adafruit-dht
    configargparse
    prometheus_client
  ];
}
