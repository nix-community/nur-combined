{pkgs, fetchFromGitHub}:
with pkgs.python3.pkgs;

buildPythonPackage rec {
  pname = "prison-break";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "makefu";
    repo = pname;
    rev = "5eed6371e151e716faafa054e005bd98d77b4b5d";
    sha256 = "170zs9grbgkx83ghg6pm13v7vhi604y44j550ypp2x26nidaw63j";
  };
  propagatedBuildInputs = [
    docopt
    requests
    beautifulsoup4
    (callPackage ./straight-plugin.nix {})
  ];
  checkInputs = [ black ];
}
