{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "pre-commit";
  version = "4.5.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pre-commit";
    repo = "pre-commit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3E/haU7TzTr+Qj3KadC7BYwuECZPa2Q+NvG5e4SSKSA=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    cfgv
    identify
    nodeenv
    pyyaml
    virtualenv
    # re-assert # TODO move to checkInputs
  ];

  # doCheck = false; # no effect
  dontUsePytestCheck = true;

  pythonImportsCheck = [
    "pre_commit"
  ];

  meta = {
    description = "A framework for managing and maintaining multi-language pre-commit hooks";
    homepage = "https://github.com/pre-commit/pre-commit";
    changelog = "https://github.com/pre-commit/pre-commit/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pre-commit";
  };
})
