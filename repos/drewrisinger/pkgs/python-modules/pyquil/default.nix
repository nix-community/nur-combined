{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, antlr4-python3-runtime
, lark-parser ? null  # <= nixos-21.11
, lark ? null # > nixos-21.11
, importlib-metadata
, networkx
, numpy
, qcs-api-client
, rpcq
, requests
, retry
, scipy
  # Check Inputs
, pytestCheckHook
, ipython
, pytestcov
, pytest-mock
, pytest-httpx ? null
, requests-mock
}:

buildPythonPackage rec {
  pname = "pyquil";
  version = "3.1.0";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ejfzxCf2NucK/hfzswHu3h4DPPZQY8vkMAQ51XDRWKU=";
  };
  postPatch = ''
    # remove hard-pinning
    substituteInPlace pyproject.toml \
      --replace "^" ">=" \
      --replace "lark" "${if lark != null then "lark" else "lark-parser"}"
  '';

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    antlr4-python3-runtime
    lark-parser # <= nixos-21.11
    lark  # > nixos-21.11
    networkx
    numpy
    qcs-api-client
    requests
    retry
    rpcq
    scipy
  ] ++ (lib.optionals (pythonOlder "3.8") [ importlib-metadata ]);

  doCheck = false; # tests are complex, seem to depend on certain processes/servers run in docker container.
  checkInputs = [
    pytestCheckHook
    ipython
    pytestcov
    pytest-mock
    pytest-httpx
    requests-mock
  ];
  # Seem to require network connection??
  disabledTests = [
    "test_invalid_protocol"
    "test_qc_noisy"
    "test_qc_compile"
    "qvm" # seem to expect network connection
  ];
  pythonImportsCheck = [ "pyquil" ];

  meta = with lib; {
    description = "A library for quantum programming using Quil.";
    homepage = "https://docs.rigetti.com/en/";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
    broken = (lark-parser != null) && (lib.versionOlder lark-parser.version "0.11.1"); # generating parser fails on older versions of Lark parser. Exact version compatibility unknown
  };
}
