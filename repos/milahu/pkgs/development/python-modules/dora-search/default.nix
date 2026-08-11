{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  hydra-core,
  pytorch-lightning,
  retrying,
  torch,
  treetable,
  submitit,
}:

buildPythonPackage (finalAttrs: {
  pname = "dora-search";
  version = "0.1.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "dora";
    tag = "v${finalAttrs.version}";
    hash = "sha256-v18FgiBdlNSGQmCnq63wCxcO8kJCPsUt0VznUlSPyoM=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    hydra-core
    pytorch-lightning
    retrying
    torch
    treetable
    submitit
  ];

  pythonImportsCheck = [
    "dora"
  ];

  meta = {
    description = "Dora is an experiment management framework. It expresses grid searches as pure python files as part of your repo. It identifies experiments with a unique hash signature. Scale up to hundreds of experiments without losing your sanity";
    homepage = "https://github.com/facebookresearch/dora";
    changelog = "https://github.com/facebookresearch/dora/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
