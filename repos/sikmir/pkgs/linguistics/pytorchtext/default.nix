{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  cmake,
  which,
  revtok,
}:

python3Packages.buildPythonPackage rec {
  pname = "pytorchtext";
  version = "0.10.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "text";
    tag = "v${version}";
    hash = "sha256-UCH/12jVeUY+h3Qop/RPtjIeXdddA1upsWIiwAs8+bc=";
    fetchSubmodules = true;
  };

  build-system = with python3Packages; [ setuptools ];

  nativeBuildInputs = [
    cmake
    which
  ];

  buildInputs = with python3Packages; [ pybind11 ];

  dependencies = with python3Packages; [
    defusedxml
    nltk
    pytorch
    requests
    revtok
    sacremoses
    spacy
    tqdm
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  dontUseCmakeConfigure = true;

  doCheck = false;

  pythonImportsCheck = [ "torchtext" ];

  meta = {
    description = "Text utilities and datasets for PyTorch";
    homepage = "https://github.com/pytorch/text";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true; # spacy is broken
  };
}
