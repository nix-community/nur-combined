{ lib, python3, callPackage, hledger }:

let drawilleplot = callPackage ../drawilleplot { };
in python3.pkgs.buildPythonApplication rec {
  pname = "hledger-utils";
  version = "1.12.0";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-5i13XzO9LUqBY22nvSWjWRQOgh0YM9+KkLSlWv6h6CM=";
  };

  nativeBuildInputs = [ hledger ];

  propagatedBuildInputs = with python3.pkgs; [
    rich
    psutil
    matplotlib
    pandas
    cycler
    numpy
    scipy
    drawilleplot
    asteval
  ];

  patchPhase = ''
    echo "from setuptools import setup, find_packages" > setup.py
    echo "setup()" >> setup.py
  '';

  # no tests
  doCheck = false;

  meta = with lib; {
    description = "Utilities enhancing hledger";
    homepage = "https://gitlab.com/nobodyinperson/hledger-utils";
    license = licenses.mit;
    maintainers = with maintainers; [ renesat ];
  };
}
