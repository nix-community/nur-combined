{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
, antlr4-python3-runtime
, immutables
, lark-parser
, networkx
, numpy
, rpcq
, requests
, scipy
  # Check Inputs
, pytestCheckHook
, ipython
, pytestcov
, requests-mock
}:

buildPythonPackage rec {
  pname = "pyquil";
  version = "2.28.1";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-KkixNgtjZhbFj839oxkmhdjYIht4lw50ADFJtMoKqB8=";
  };

  propagatedBuildInputs = [
    antlr4-python3-runtime
    immutables
    lark-parser
    networkx
    numpy
    scipy
    rpcq
    requests
  ];

  patches = [
    (fetchpatch {
      name = "pyquil-pr-1321-use-lark-parser.patch";
      url = "https://github.com/rigetti/pyquil/commit/356f4db83d46d334e423f75583131b38ccd243d7.patch";
      sha256 = "1ipgv1zn7vf7faxy29g95j4fi8w0zv62q85lyjac03lyh73j59xq";
    })
  ];
  postPatch = ''
    substituteInPlace setup.py --replace "immutables==0.6" "immutables"
  '';

  dontUseSetuptoolsCheck = true;
  checkInputs = [
    pytestCheckHook
    ipython
    pytestcov
    requests-mock
  ];
  # Seem to require network connection??
  disabledTests = [
    "test_invalid_protocol"
    "test_qc_noisy"
    "test_qc_compile"
    "qvm" # seem to expect network connection
  ];

  meta = with lib; {
    description = "A library for quantum programming using Quil.";
    homepage = "https://docs.rigetti.com/en/";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
