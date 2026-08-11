{
  lib,
  python,
  repro-zipfile,
  typer,
}:

python.pkgs.buildPythonApplication rec {
  pname = "rpzip";
  inherit (repro-zipfile) version src build-system;

  pyproject = true;

  sourceRoot = "source/cli";

  dependencies = [
    repro-zipfile
    typer
  ];

  pythonImportsCheck = [
#    "repro_zipfile"
  ];

  meta = repro-zipfile.meta // {
    mainProgram = "rpzip";
  };
}
