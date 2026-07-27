{ lib
, fetchFromGitHub
, buildPythonPackage
, fairscale
, opencv4
, prefix-python-modules
, pycocoevalcap
, pycocotools
, ruamel-yaml
, setuptools
, timm
, torch
, torchvision
, transformers
, wheel
}:

buildPythonPackage rec {
  pname = "blip";
  version = "unstable-2022-09-20";
  pyproject = true;
  pyprojectToml = ./pyproject.toml;

  src = fetchFromGitHub {
    owner = "salesforce";
    repo = "BLIP";
    rev = "3a29b7410476bf5f2ba0955827390eb6ea1f4f9d";
    hash = "sha256-WX+raOYWrDdODF+AwKtDMep5+2o1Xyr4cKW02OwA9EU=";
  };

  postPatch = ''
    prefix-python-modules . --prefix $pname \
      --rename-external ruamel_yaml ruamel "**"
    cp $pyprojectToml pyproject.toml
  '';

  nativeBuildInputs = [
    prefix-python-modules
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    fairscale
    opencv4
    pycocoevalcap
    pycocotools
    ruamel-yaml
    timm
    torch
    torchvision
    transformers
  ];

  pythonImportsCheck = [
    "blip.models.blip"
    "blip.models.vit"
    "blip.transform.randaugment"
    # Depends on https://pypi.org/project/cog/?
    # "blip.predict"
    "blip.pretrain"
    "blip.train_retrieval"
  ];

  meta = with lib; {
    description = "PyTorch code for BLIP: Bootstrapping Language-Image Pre-training for Unified Vision-Language Understanding and Generation";
    homepage = "https://github.com/salesforce/BLIP";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    mainProgram = "blip";
    platforms = platforms.all;
  };
}
