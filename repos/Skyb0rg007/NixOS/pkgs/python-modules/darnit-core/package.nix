{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  anthropic,
  cel-python,
  jinja2,
  mcp,
  packaging,
  pydantic,
  pydantic-ai-slim,
  pyyaml,
  ruamel-yaml,
  nix-update-script,
}:

buildPythonPackage (finalAttrs: {
  pname = "darnit-core";
  version = "0.1.1";
  __structuredAttrs = true;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "darnitdevorg";
    repo = "darnit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/K1ryC8fQU+yJDqzGWV0ckAoGOGSjMNXR4GnokJFnWs=";
  };

  sourceRoot = "${finalAttrs.src.name}/packages/darnit";

  build-system = [ hatchling ];

  dependencies = [
    # pydantic-ai-slim[anthropic]
    anthropic
    cel-python
    jinja2
    mcp
    # Imported at runtime but not declared upstream
    packaging
    pydantic
    pydantic-ai-slim
    pyyaml
    ruamel-yaml
  ]
  ++ pydantic.optional-dependencies.email;

  doCheck = false;

  pythonImportsCheck = [ "darnit" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Generic compliance audit framework with plugin architecture";
    homepage = "https://github.com/darnitdevorg/darnit";
    changelog = "https://github.com/darnitdevorg/darnit/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "darnit";
  };
})
