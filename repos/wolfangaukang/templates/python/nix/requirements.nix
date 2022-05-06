{ refpkgs }:

let
  inherit (refpkgs) python39 python39Packages;
  # Replace buildPythonApplication with buildPythonPackage if required
  inherit (python39Packages) black buildPythonApplication poetry-core pytest;

in rec {
  python = python39;
  # Replace buildPythonApplication with buildPythonPackage if required
  buildMethod = buildPythonApplication;

  nativeBuildInputs = [ poetry-core ];

  base = [];
  tests = [ pytest ];
  dev = [ black ];
}
