{ lib, buildPythonPackage, fetchPypi, z3-solver, pythonOlder, setuptools, setuptools-scm, sortedcontainers, toml, pythonRelaxDepsHook }:

buildPythonPackage rec {
  pname = "halmos";
  version = "0.1.14";
  pyproject = true;
  doCheck = false;
  disabled = pythonOlder "3.11";

  nativeBuildInputs = [
    z3-solver
  ];
  
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Va5gwyRePGHnFr3jtP1ec3diAQExXfVbwrrMpzV9euc=";
  };
  
  build-system = [
    pythonRelaxDepsHook
    setuptools
    setuptools-scm
  ];

  pythonRemoveDeps = [ "z3-solver" ]; # https://github.com/NixOS/nixpkgs/blob/1d28f484f4a92f6ef8facea80ea4e3fe3aa153bc/pkgs/development/python-modules/model-checker/default.nix#L24-L25
  
  dependencies = [
    sortedcontainers
    z3-solver
    toml
  ] ++ z3-solver.requiredPythonModules;
  
  meta = {
    broken = false;
    description = "A symbolic testing tool for EVM smart contracts";
    homepage = "https://github.com/a16z/halmos";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.agpl3Only;
  };
}
