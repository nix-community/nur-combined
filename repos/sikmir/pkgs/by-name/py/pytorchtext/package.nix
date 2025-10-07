{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  cmake,
  ninja,
  which,
  revtok,
}:

python3Packages.buildPythonPackage rec {
  pname = "pytorchtext";
  version = "0.18.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "text";
    tag = "v${version}";
    hash = "sha256-ok91rw/76ivtTTd3DkdDG7N2aZE5WqPuZE4YbbQ0pYU=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "subprocess.check_call" "pass #"
  '';

  build-system = with python3Packages; [ setuptools ];

  nativeBuildInputs = [
    cmake
    ninja
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

  env.NIX_CFLAGS_COMPILE = "-Wno-error=enum-constexpr-conversion";

  pythonImportsCheck = [ "torchtext" ];

  meta = {
    description = "Text utilities and datasets for PyTorch";
    homepage = "https://github.com/pytorch/text";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true; # error: implicit instantiation of undefined template 'std::char_traits'
  };
}
