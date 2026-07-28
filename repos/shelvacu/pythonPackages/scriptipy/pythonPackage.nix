{
  buildPythonPackage,
  hatchling,
  pyright,

  # things that are useful to have that I want to include by default in anything using scriptipy, but scriptipy doesn't use directly
  pydantic,
  requests,
  vacu-humanfriendly,
  httpx,
}:
buildPythonPackage {
  pname = "scriptipy";
  version = "whatever";
  pyproject = true;

  src = ./.;

  build-system = [ hatchling ];

  dependencies = [
    pydantic
    requests
    vacu-humanfriendly
    httpx
  ];

  nativeCheckInputs = [ pyright ];

  doCheck = true;

  checkPhase = ''
    pyright .
  '';
}
