{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  # Dependencies
  numpy,
  torch,
  torch-complex,
}:
buildPythonPackage (finalAttrs: {
  pname = "pytorch-wpe";
  version = "0.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nttcslab-sp";
    repo = "dnn_wpe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DcT0NnnbcSYYyVpH7JqAnpjOANS2INBYQLV9Qx3BwZw=";
  };
  build-system = [ setuptools ];

  propagatedBuildInputs = [
    numpy
    torch
    torch-complex
  ];

  pythonImportsCheck = [ "pytorch_wpe" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/nttcslab-sp/dnn_wpe/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "WPE implementation using PyTorch";
    homepage = "https://github.com/nttcslab-sp/dnn_wpe";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
})
