{ lib
, buildPythonPackage
, fetchFromGitHub
, hatchling
, einops
, fairscale
, fire
, fsspec
, invisible-watermark
, kornia
, matplotlib
, natsort
, numpy
, omegaconf
, onnx
, open-clip-torch
, opencv4
, pandas
, pillow
, pudb
, pytorch-lightning
, pyyaml
, scipy
, streamlit
, tensorboardx
, timm
, tokenizers
, torch
, torchdata
, torchmetrics
, torchvision
, tqdm
, transformers
, triton
, urllib3
, wandb
, webdataset
, xformers
}:

buildPythonPackage rec {
  pname = "stability-ai-generative-models";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Stability-AI";
    repo = "generative-models";
    rev = version;
    hash = "sha256-qaZeaCfOO4vWFZZAyqNpJbTttJy17GQ5+DM05yTLktA=";
  };

  nativeBuildInputs = [
    hatchling
  ];

  propagatedBuildInputs = [
    pytorch-lightning
    # clip @ git+https://github.com/openai/CLIP.git
    einops
    fairscale
    fire
    fsspec
    invisible-watermark
    kornia
    matplotlib
    natsort
    numpy
    omegaconf
    onnx
    open-clip-torch
    opencv4
    pandas
    pillow
    pudb
    pytorch-lightning
    pyyaml
    scipy
    streamlit
    tensorboardx
    timm
    tokenizers
    torch
    # They probably don't need it
    # torchaudio
    torchdata
    torchmetrics
    torchvision
    tqdm
    transformers
    triton
    urllib3
    wandb
    webdataset
    xformers
  ];

  pythonImportsCheck = [ "sgm" ];

  meta = with lib; {
    description = "Generative Models by Stability AI";
    homepage = "https://github.com/Stability-AI/generative-models.git";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
