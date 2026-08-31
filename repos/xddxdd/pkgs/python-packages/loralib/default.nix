{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  unstableGitUpdater,
  setuptools,
  # Dependencies
  torch,
}:
buildPythonPackage (finalAttrs: {
  pname = "loralib";
  version = "0-unstable-2024-12-16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "LoRA";
    rev = "c4593f060e6a368d7bb5af5273b8e42810cdef90";
    hash = "sha256-f0ZZYZyCtlpXwF9F+iVR4fjDQQMzXOnQGcF6xWzRshA=";
  };
  build-system = [ setuptools ];

  propagatedBuildInputs = [
    torch
  ];

  pythonImportsCheck = [ "loralib" ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/microsoft/LoRA";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Implementation of \"LoRA: Low-Rank Adaptation of Large Language Models\"";
    homepage = "https://arxiv.org/abs/2106.09685";
    license = with lib.licenses; [ mit ];
  };
})
