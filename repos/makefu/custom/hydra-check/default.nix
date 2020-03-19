{ docopt, requests, beautifulsoup4, fetchFromGitHub, buildPythonPackage }:

buildPythonPackage rec {
  name = "hydra-check";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "hydra-check";
    rev = version;
    sha256 = "1q4n5l238lnzcms3z1ax4860inaliawqlxv7nf1wb4knl4wr26fk";
  };
  propagatedBuildInputs = [
    docopt
    requests
    beautifulsoup4
  ];
  doCheck = false; # no tests
}
