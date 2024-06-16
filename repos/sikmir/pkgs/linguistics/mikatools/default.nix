{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "mikatools";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "mikahama";
    repo = "mikatools";
    rev = version;
    hash = "sha256-2YpRTSZWJVXMoTLDBFS+tFkmA8pOBsqWF7Z85gtIfY0=";
  };

  dependencies = with python3Packages; [
    requests
    cryptography
    tqdm
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Mikatools provides fast and easy methods for common Python coding tasks";
    homepage = "https://github.com/mikahama/mikatools";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
