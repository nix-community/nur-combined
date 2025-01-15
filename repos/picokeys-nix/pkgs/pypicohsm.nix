{
  lib,
  fetchFromGitHub,
  python3,
  pycvc,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "pypicohsm";
  version = "1.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "polhenarejos";
    repo = "pypicohsm";
    rev = "v${version}";
    hash = "sha256-qWJH5CYtNYgWzYXB1vo4VoxilqFkJ4yGrVvTgBup5k0=";
  };

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    cryptography
    base58
    pyusb
    pycvc
    pyscard
  ];

  doCheck = false;

  pythonImportsCheck = [
    "picohsm"
  ];

  meta = {
    description = "Pico HSM client for Python";
    homepage = "https://github.com/polhenarejos/pypicohsm";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
