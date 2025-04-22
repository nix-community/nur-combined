{ lib
, buildPythonPackage
, fetchFromGitHub
, hatchling
, cython
, setuptools
, mypy
, pytest
, pytest-cov
}:

buildPythonPackage rec {
  pname = "bencode2";
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "trim21";
    repo = "bencode-py";
    rev = "v${version}";
    hash = "sha256-pzCNEpMVcUEvIOtUMez1fr3CVSOPnRZbervJw50893E=";
  };

  nativeBuildInputs = [
    hatchling
  ];

  passthru.optional-dependencies = {
    cython = [
      cython
      setuptools
    ];
    mypy = [
      mypy
    ];
    testing = [
      pytest
      pytest-cov
    ];
  };

  pythonImportsCheck = [ "bencode2" ];

  meta = with lib; {
    description = "A fast and correct bencode serialize/deserialize library";
    homepage = "https://github.com/trim21/bencode-py";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
