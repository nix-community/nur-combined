{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gostcrypto";
  version = "1.2.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "drobotun";
    repo = "gostcrypto";
    rev = "ver_${version}";
    hash = "sha256-nW2OqWCN0CZxnJbKMj3d8Gk6Zv2NkNBcTlc7UYnfv0A=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [
    "gostcrypto"
  ];

  meta = {
    description = "GOST cryptographic functions";
    homepage = "https://github.com/drobotun/gostcrypto";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "gostcrypto";
  };
}
