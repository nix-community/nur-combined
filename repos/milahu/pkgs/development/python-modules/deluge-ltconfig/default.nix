{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  deluge,
}:

buildPythonPackage rec {
  pname = "deluge-ltconfig";
  version = "2.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "zakkarry";
    repo = "deluge-ltconfig";
    rev = "v${version}";
    hash = "sha256-EN7TyJSS9iHgYXf6/N/PAeHw9ja0rvQDizEM1UjiFEM=";
  };

  dependencies = [
    deluge
  ];

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [
    "ltconfig"
  ];

  meta = {
    description = "LtConfig plugin for Deluge 2.x with High-Speed \"zakkarry's advanced preset\" built-in";
    homepage = "https://github.com/zakkarry/deluge-ltconfig";
    changelog = "https://github.com/zakkarry/deluge-ltconfig/blob/${src.rev}/changelog";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ];
  };
}
