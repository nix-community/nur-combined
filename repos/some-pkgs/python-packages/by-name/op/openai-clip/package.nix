{ lib
, buildPythonPackage
, fetchFromGitHub
, ftfy
, regex
, torch
, torchvision
, tqdm
}:

buildPythonPackage rec {
  pname = "openai-clip";
  version = "unstable-2023-07-08";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "openai";
    repo = "CLIP";
    rev = "a1d071733d7111c9c014f024669f959182114e33";
    hash = "sha256-NOiKadc5DYvE94NEHPvlUn4e8lvW2k0NkyEACAxekGQ=";
  };

  propagatedBuildInputs = [
    ftfy
    regex
    torch
    torchvision
    tqdm
  ];

  pythonImportsCheck = [ "clip" ];

  meta = with lib; {
    description = "CLIP (Contrastive Language-Image Pretraining),  Predict the most relevant text snippet given an image";
    homepage = "https://github.com/openai/CLIP";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
