{ lib, python3, fetchPypi }:

python3.pkgs.buildPythonPackage rec {
  pname = "halmos";
  version = "0.2.0";
  pyproject = true;
  doCheck = false;

  nativeBuildInputs = with python3.pkgs; [
    z3-solver
  ];
  
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1Js1ovvPgAZLngArTmu0vhM9vk5LZTg68eYptsn3Ji4=";
  };
  
  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  # z3 does not provide a dist-info, so python-runtime-deps-check will fail
  pythonRemoveDeps = [ "z3-solver" ];
  
  dependencies = with python3.pkgs; [
    sortedcontainers
    z3-solver
    toml
  ] ++ python3.pkgs.z3-solver.requiredPythonModules;
  
  meta = {
    broken = false;
    description = "A symbolic testing tool for EVM smart contracts";
    homepage = "https://github.com/a16z/halmos";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.agpl3Only;
  };
}
