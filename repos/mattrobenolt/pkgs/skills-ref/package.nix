{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "skills-ref";
  inherit (versionData) version;

  pyproject = true;

  src = fetchFromGitHub {
    owner = "agentskills";
    repo = "agentskills";
    inherit (versionData) rev;
    hash = versionData.sourceHash;
  };

  # skills-ref lives in a subdirectory of the agentskills monorepo.
  sourceRoot = "${finalAttrs.src.name}/skills-ref";

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    click
    strictyaml
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "skills_ref" ];

  meta = with lib; {
    description = "Reference library and CLI for Agent Skills";
    homepage = "https://github.com/agentskills/agentskills/tree/main/skills-ref";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "skills-ref";
    platforms = platforms.unix;
  };
})
