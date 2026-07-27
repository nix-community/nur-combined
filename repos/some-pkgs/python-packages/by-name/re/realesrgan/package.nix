{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, basicsr
, cython_3
, facexlib
, gfpgan
, numpy
, opencv4
, pillow
, torch
, torchvision
, tqdm
}:

buildPythonPackage rec {
  pname = "realesrgan";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "xinntao";
    repo = "Real-ESRGAN";
    rev = "v${version}";
    hash = "sha256-pdOYDOAnKKt+5M6dD8ksTbFoA8EwjGUZVx+UGpxCF6c=";
  };

  nativeBuildInputs = [
    cython_3
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    basicsr
    facexlib
    gfpgan
    numpy
    opencv4
    pillow
    torch
    torchvision
    tqdm
  ];

  pythonImportsCheck = [ "realesrgan" ];

  meta = with lib; {
    description = "Real-ESRGAN aims at developing Practical Algorithms for General Image/Video Restoration";
    homepage = "https://github.com/xinntao/Real-ESRGAN";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
