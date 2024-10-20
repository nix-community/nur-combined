{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "tinynetrc";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "sloria";
    repo = "tinynetrc";
    rev = version;
    hash = "sha256-iy0sa1oqJeZxSfXISI7Ypbml8+SGHhRZkznTdbI5yAo=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  pythonImportsCheck = [ "tinynetrc" ];

  meta = {
    description = "Read and write .netrc files in Python";
    homepage = "https://github.com/sloria/tinynetrc";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
