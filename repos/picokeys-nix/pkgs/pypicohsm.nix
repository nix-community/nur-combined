{
  lib,
  fetchFromGitHub,
  python3,
  pycvc,
}:
python3.pkgs.buildPythonPackage {
  pname = "pypicohsm";
  version = "unstable-2024-06-19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "polhenarejos";
    repo = "pypicohsm";
    rev = "83cb202aa73ec3c8aab45e2c5abcd42e4582bd39";
    hash = "sha256-glx0O70B+5UcMbjuK5MOHj2hPn9kqOP2v3pXPvXIIco=";
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
