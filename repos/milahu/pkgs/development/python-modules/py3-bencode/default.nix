{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "py3-bencode";
  version = "0.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bashkirtsevich-llc";
    repo = "py3bencode";
    rev = "a35ca3346e88df11fc7a5da8d0c5b38c11acc58f";
    hash = "sha256-jsS2pPku68BHs7a+i4uEOoZV0DDAhN7MQm2kOhYPYXc=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail \
        ' python_requires=">=3.6.*"' \
        ' python_requires=">=3.6"'
  '';

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "bencode"
  ];

  meta = {
    description = "Python 3.7 bencoding library";
    homepage = "https://github.com/bashkirtsevich-llc/py3bencode";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
})
