{
  lib,
  python3,
  fetchFromGitLab,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "asncounter";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "anarcat";
    repo = "asncounter";
    tag = version;
    hash = "sha256-1KFkRwaiOWR/89SDObCatydpyFZd1+xikvpAymQhU+Q=";
  };

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    pyasn
  ];

  nativeCheckInputs = with python3.pkgs; [
      pytestCheckHook
  ];

  optional-dependencies = with python3.pkgs; {
    full = [
      manhole
      netaddr
      prometheus-client
      scapy
    ];
  };

  pythonImportsCheck = [
    "asncounter"
  ];

  meta = {
    description = "Count the number of hits (HTTP, packets, etc) per autonomous system\r\nnumber (ASN) and related network blocks";
    homepage = "https://gitlab.com/anarcat/asncounter";
    license = lib.licenses.agpl3Only;
    mainProgram = "asncounter";
  };
}
