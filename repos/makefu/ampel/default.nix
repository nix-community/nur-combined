{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.python3Packages;buildPythonPackage rec {
  name = "ampel-${version}";
  version = "0.2.1";

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
      rev = "92321d7";
      sha256 = "0mvpbpf1rx8sc589qjb73gl8z6fir2zs3gl3br1pbhg5jgn0ij4n";
  };
  meta = {
    homepage = http://cgit.euer.krebsco.de/ampel;
    description = "change colors of rgb cubes";
    license = lib.licenses.asl20;
  };
}
