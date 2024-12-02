{ lib, pkgs, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "mlxp";
  version = "1.0.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "inria-thoth";
    repo = "mlxp";
    rev = "${version}";
    sha256 = "sha256-Y8Qoxf3+rCHIuK+Awh2YhIwvuscmrIiTNoglcpycAhw=";
  };

  nativeBuildInputs = [ python3Packages.setuptools ];
  propagatedBuildInputs = with python3Packages; [
    dill
    gitpython
    hydra-core
    pandas
    ply
    pyyaml
    tinydb
  ];

  meta = with lib; {
    longDescription = ''MLXP (Machine Learning eXperimentalist for Python) package is an open-source Python framework for managing multiple experiments with a flexible option structure from launching, and logging to querying results.'';
    description = ''Machine Learning eXperimentalist for Python.'';
    homepage = "https://inria-thoth.github.io/mlxp/";
    platforms = platforms.all;
    license = licenses.mit;
    broken = false;
  };
}
