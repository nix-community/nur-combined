{ lib
, buildPythonPackage
, fetchFromGitHub
, jupyter
, matplotlib
, numpy
, opencv4
, scikitimage
, scipy
, torch
, torchvision
, tqdm
, unittestCheckHook
}:

buildPythonPackage rec {
  pname = "lpips";
  version = "0.1.4";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "richzhang";
    repo = "PerceptualSimilarity";
    rev = "v${version}";
    hash = "sha256-dIQ9B/HV/2kUnXLXNxAZKHmv/Xv37kl2n6+8IfwIALE=";
  };

  propagatedBuildInputs = [
    jupyter
    matplotlib
    numpy
    opencv4
    scikitimage
    scipy
    torch
    torchvision
    tqdm
  ];

  nativeBuildInputs = [
    unittestCheckHook
  ];

  # load_state_dict_from_url fails
  doCheck = false;
  dontUseSetuptoolsCheck = true;
  dontUseUnittestCheck = true;

  pythonImportsCheck = [ "lpips" ];

  meta = with lib; {
    description = "LPIPS metric. pip install lpips";
    homepage = "https://github.com/richzhang/PerceptualSimilarity";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
