{ lib, stdenv, fetchFromGitHub, python3Packages, cmake, which, revtok }:

python3Packages.buildPythonPackage rec {
  pname = "pytorchtext";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "text";
    rev = "v${version}";
    hash = "sha256-UCH/12jVeUY+h3Qop/RPtjIeXdddA1upsWIiwAs8+bc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake which ];

  buildInputs = with python3Packages; [ pybind11 ];

  propagatedBuildInputs = with python3Packages; [
    defusedxml
    nltk
    pytorch
    requests
    revtok
    sacremoses
    spacy
    tqdm
  ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  dontUseCmakeConfigure = true;

  doCheck = false;

  pythonImportsCheck = [ "torchtext" ];

  meta = with lib; {
    description = "Text utilities and datasets for PyTorch";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    #broken = stdenv.isDarwin; # https://github.com/NixOS/nixpkgs/issues/94241
    broken = true; # sentry-sdk
  };
}
