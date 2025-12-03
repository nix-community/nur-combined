{
  lib,
  python3,
}:

python3.pkgs.buildPythonPackage {
  name = "project";
  format = "pyproject";

  src = lib.cleanSource ./.;

  build-system = [ python3.pkgs.hatchling ];

  meta = {
    description = "Project description";
    #homepage = "https://project.page";
    license = lib.licenses.gpl3Only;
    #mainProgram = "project";
  };
}
