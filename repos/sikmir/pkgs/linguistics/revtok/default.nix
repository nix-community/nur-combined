{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "revtok";
  version = "2018-09-21";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jekbradbury";
    repo = "revtok";
    rev = "f1998b72a941d1e5f9578a66dc1c20b01913caab";
    hash = "sha256-o416UUnTMejCd57fGvZPSFQv0bT4PULdgNTXyAzMiMs=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ tqdm ];

  pythonImportsCheck = [ "revtok" ];

  meta = {
    description = "Reversible tokenization in Python";
    homepage = "https://github.com/jekbradbury/revtok";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
