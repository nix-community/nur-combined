{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "hierplace";
  version = "0-unstable-2023-08-10";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "devbisme";
    repo = "HierPlace";
    rev = "c70315f08257e73115e67cae650e38c940c8c7f8";
    hash = "sha256-UhNl9TtMv/dk6iPQtfP3Uc8H3ZHCEqnZGCYF9oGsy6E=";
  };

  build-system = [
    setuptools
  ];

  # The `pcbnew` module comes from KiCad, not from PyPI. It is provided
  # at runtime via the `kicad` package (kicad.base), so the import is only
  # possible when that path is on PYTHONPATH. We skip the build-time import
  # check to avoid pulling KiCad in as a build dependency.
  # pythonImportsCheck = [ "hierplace" ];

  meta = {
    description = "Groups and arranges KiCad PCBNEW parts so they reflect the design hierarchy";
    homepage = "https://github.com/devbisme/HierPlace";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
