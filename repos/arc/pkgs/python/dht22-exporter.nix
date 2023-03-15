{ lib, stdenv, fetchFromGitHub, fetchpatch, pythonPackages, adafruit-dht ? pythonPackages.adafruit-dht }:

with pythonPackages;

buildPythonApplication rec {
  pname = "dht22_exporter";
  version = "2021.09.06";

  src = fetchFromGitHub {
    owner = "clintjedwards";
    repo = pname;
    rev = "0be653a2c9ea3edc3cc1e59202f19c61fa809899";
    sha256 = "10fsvcmnzvsrq5x5zh824zwz0mngx28b2cgrckx7zzq2rk67fnqx";
  };

  propagatedBuildInputs = [
    adafruit-dht
    configargparse
    prometheus_client
  ];
}
