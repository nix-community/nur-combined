{
  buildPythonPackage,
  hatchling,
  pyright,
}:
buildPythonPackage {
  pname = "scriptipy";
  version = "whatever";
  pyproject = true;

  src = ./.;

  build-system = [ hatchling ];

  nativeCheckInputs = [ pyright ];

  doCheck = true;

  checkPhase = ''
    pyright .
  '';
}
