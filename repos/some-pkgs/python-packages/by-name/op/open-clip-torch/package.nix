{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, ftfy
, huggingface-hub
, prefix-python-modules
, protobuf
, regex
, sentencepiece
, timm
, torch
, torchvision
, tqdm
}:

buildPythonPackage rec {
  pname = "open-clip-torch";
  version = "2.23.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mlfoundations";
    repo = "open_clip";
    rev = "v${version}";
    hash = "sha256-Txm47Tc4KMbz1i2mROT+IYbgS1Y0yHK80xY0YldgBFQ=";
  };

  postPatch = ''
    prefix-python-modules src/ --prefix open_clip
  '';

  nativeBuildInputs = [
    setuptools
    wheel
    prefix-python-modules
  ];

  propagatedBuildInputs = [
    ftfy
    huggingface-hub
    protobuf
    regex
    sentencepiece
    timm
    torch
    torchvision
    tqdm
  ];

  pythonImportsCheck = [ "open_clip" "open_clip.training" ];

  meta = with lib; {
    description = "An open source implementation of CLIP";
    homepage = "https://github.com/mlfoundations/open_clip";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
