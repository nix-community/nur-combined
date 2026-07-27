{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, accelerate
, clean-fid
, clip-anytorch
, dctorch
, einops
, jsonmerge
, kornia
, pillow
, prefix-python-modules
, safetensors
, scikit-image
, scipy
, torch
, torchdiffeq
, torchsde
, torchvision
, tqdm
, wandb
}:

buildPythonPackage rec {
  pname = "k-diffusion";
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "crowsonkb";
    repo = "k-diffusion";
    rev = "v${version}";
    hash = "sha256-ef4NhViHQcV+4T+GXpg+Qev5IC0Cid+XWE3sFVx7w4w=";
  };

  postPatch = ''
    prefix-python-modules . --prefix k_diffusion --exclude-glob 'setup*'
  '';

  nativeBuildInputs = [
    setuptools
    wheel
    prefix-python-modules
  ];

  propagatedBuildInputs = [
    accelerate
    clean-fid
    clip-anytorch
    dctorch
    einops
    jsonmerge
    kornia
    pillow
    safetensors
    scikit-image
    scipy
    torch
    torchdiffeq
    torchsde
    torchvision
    tqdm
    wandb
  ];

  pythonImportsCheck = [
    "k_diffusion"
    "k_diffusion.layers"
  ];

  meta = with lib; {
    description = "Karras et al. (2022) diffusion models for PyTorch";
    homepage = "https://github.com/crowsonkb/k-diffusion";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
