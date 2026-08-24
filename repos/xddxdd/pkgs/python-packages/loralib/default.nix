{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  # Dependencies
  torch,
}:
buildPythonPackage (finalAttrs: {
  pname = "loralib";
  version = "RoBERTa-large-unstable-2024-12-17";
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Implementation of \"LoRA: Low-Rank Adaptation of Large Language Models\"";
    homepage = "https://arxiv.org/abs/2106.09685";
    license = with lib.licenses; [ mit ];
  };
})
