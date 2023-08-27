{ lib
, buildPythonPackage
, fetchFromGitHub
, numpy
, cudaPackages
}:

buildPythonPackage rec {
  pname = "nvjpeg-python";
  version = "unstable-2021-05-24";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "UsingNet";
    repo = "nvjpeg-python";
    rev = "55015e272875c3bcaf004398840c20d728c6f229";
    hash = "sha256-QnMF6DO/N44sArX/eOPPI3kWWGZNdzmtyHgChedoWtQ=";
  };

  nativeBuildInputs = [
    numpy
    cudaPackages.cuda_nvcc
  ];
  buildInputs = [
    cudaPackages.libnvjpeg
    cudaPackages.cuda_cudart
    cudaPackages.cuda_nvcc
  ];
  propagatedBuildInptus = [
    numpy
  ];
  pythonImportsCheck = [ "nvjpeg" ];

  meta = with lib; {
    description = "nvjpeg for python";
    homepage = "https://github.com/UsingNet/nvjpeg-python";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
