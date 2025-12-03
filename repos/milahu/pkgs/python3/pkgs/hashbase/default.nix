{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "hashbase";
  version = "1.1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hasnainroopawalla";
    repo = "hashbase";
    rev = "v${version}";
    hash = "sha256-52WZf3g440v+ylqAPc0FEKotxDxL2lCzlDi66jLvbdE=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [
    "hashbase"
  ];

  meta = {
    description = "A collection of cryptographic hashing algorithms implemented in Python";
    homepage = "https://github.com/hasnainroopawalla/hashbase";
    changelog = "https://github.com/hasnainroopawalla/hashbase/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "hashbase";
  };
}
