{ lib, python3, callPackage }:

let drawille = callPackage ../drawille { };
in python3.pkgs.buildPythonPackage rec {
  pname = "drawilleplot";
  version = "0.1.0";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-ZEDroo7KkI2VxdESb2QDX+dPY4UahuuK9L0EddrxJjQ=";
  };

  propagatedBuildInputs = with python3.pkgs; [ drawille matplotlib ];

  # no tests
  # doCheck = false;

  meta = with lib; {
    description = "matplotlib backend for graph output in unicode terminals using drawille";
    homepage = "https://github.com/gooofy/drawilleplot";
    license = licenses.asl20;
    maintainers = with maintainers; [ renesat ];
  };
}
