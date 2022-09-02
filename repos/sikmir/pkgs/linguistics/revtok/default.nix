{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "revtok";
  version = "2018-09-21";

  src = fetchFromGitHub {
    owner = "jekbradbury";
    repo = "revtok";
    rev = "f1998b72a941d1e5f9578a66dc1c20b01913caab";
    hash = "sha256-o416UUnTMejCd57fGvZPSFQv0bT4PULdgNTXyAzMiMs=";
  };

  propagatedBuildInputs = with python3Packages; [ tqdm ];

  pythonImportsCheck = [ "revtok" ];

  meta = with lib; {
    description = "Reversible tokenization in Python";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
