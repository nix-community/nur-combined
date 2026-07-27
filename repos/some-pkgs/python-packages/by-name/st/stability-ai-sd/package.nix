{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, albumentations
, einops
, gradio
, imageio
, imageio-ffmpeg
, invisible-watermark
, kornia
, omegaconf
, open-clip-torch
, opencv4
, prefix-python-modules
, pudb
, python
, pytorch-lightning
, streamlit
  # , streamlit-drawable-canvas
, test-tube
, torchmetrics
, transformers
, webdataset
}:

buildPythonPackage rec {
  pname = "stability-ai-sd";
  version = "unstable-2023-03-25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Stability-AI";
    repo = "stablediffusion";
    rev = "cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf";
    hash = "sha256-yEtrz/JTq53JDI4NZI26KsD8LAgiViwiNaB2i1CBs/I=";
  };

  postPatch = ''
    substituteInPlace ldm/models/diffusion/ddpm.py \
      --replace \
        pytorch_lightning.utilities.distributed \
        pytorch_lightning.utilities.rank_zero

    prefix-python-modules . --prefix ldm --exclude-glob 'setup.py'
  '';

  nativeBuildInputs = [
    setuptools
    wheel
    prefix-python-modules
  ];

  propagatedBuildInputs = [
    albumentations
    einops
    gradio
    imageio
    imageio-ffmpeg
    invisible-watermark
    kornia
    omegaconf
    open-clip-torch
    opencv4
    pudb
    pytorch-lightning
    streamlit
    # streamlit-drawable-canvas
    test-tube
    torchmetrics
    transformers
    webdataset
  ];

  # Needs `npm build`
  pythonRemoveDeps = [ "streamlit-drawable-canvas" ];

  postInstall = ''
    cp -r configs $out/${python.sitePackages}/ldm/
  '';

  pythonImportsCheck = [
    "ldm"
    "ldm.models.diffusion.ddpm"

    # Cf. postPatch
    "pytorch_lightning.utilities.rank_zero"
  ];

  meta = with lib; {
    description = "High-Resolution Image Synthesis with Latent Diffusion Models";
    homepage = "https://github.com/Stability-AI/stablediffusion";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
