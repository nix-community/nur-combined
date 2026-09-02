{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  sexpdata,
}:

buildPythonPackage (finalAttrs: {
  pname = "kicad-skip";
  version = "0.2.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "psychogenic";
    repo = "kicad-skip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PFrfaIyh8y9dZNw4oP4IBBIM7PsA5znkDbmMfo8hFT8=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    sexpdata
  ];

  pythonImportsCheck = [
    "skip"
    "skip.sexp"
    "skip.pcbnew"
    "skip.eeschema"
  ];

  meta = {
    description = "Friendly way to skip the drudgery and manipulate kicad 7+ s-expression schematic, netlist and PCB files";
    homepage = "https://github.com/psychogenic/kicad-skip";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
