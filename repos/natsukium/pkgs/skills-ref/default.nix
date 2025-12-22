{
  source,
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  inherit (source) pname src;
  version = "0-unstable-${source.date}";
  pyproject = true;

  sourceRoot = "${src.name}/skills-ref";

  build-system = [ python3Packages.hatchling ];

  dependencies = with python3Packages; [
    click
    strictyaml
  ];

  pythonImportsCheck = "skills_ref";

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  meta = {
    description = "Reference library for Agent Skills";
    homepage = "https://github.com/agentskills/agentskills";
    license = lib.licenses.asl20;
    mainProgram = "skills-ref";
  };
}
