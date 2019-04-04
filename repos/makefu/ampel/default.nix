{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.python3Packages;buildPythonPackage rec {
  name = "ampel-${version}";
  version = "0.2.5";

  propagatedBuildInputs = [
    docopt
    paho-mqtt
    requests
    pytz
    influxdb
    httplib2
    google_api_python_client
  ];

  src = pkgs.fetchgit {
      url = "http://cgit.euer.krebsco.de/ampel";
      rev = "ce239876820699f02054e71b4fd0950509833379";
      sha256 = "1ja32lr04lwq4shi49kppa1zzjw0zlqaqy71pr5sbajgp4zj7kh8";
  };
  meta = {
    homepage = http://cgit.euer.krebsco.de/ampel;
    description = "change colors of rgb cubes";
    license = lib.licenses.asl20;
  };
}
