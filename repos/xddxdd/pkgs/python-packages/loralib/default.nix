{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
  # Dependencies
  torch,
}:
buildPythonPackage rec {
  inherit (sources.loralib) pname version src;
  pyproject = true;

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    torch
  ];

  pythonImportsCheck = [ "loralib" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Implementation of \"LoRA: Low-Rank Adaptation of Large Language Models\"";
    homepage = "https://arxiv.org/abs/2106.09685";
    license = with lib.licenses; [ mit ];
  };
}
