{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
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
  version = "3.0.1";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-OU7/LjcpCxvqlcfdlm5ll4f0DYXf0yxNprM8Muu2wyg=";
  };
  postPatch = ''
    # remove numpy hard-pinning, not compatible with nixpkgs 20.09
    substituteInPlace setup.py \
      --replace ",>=1.20.0" "" \
      --replace "lark==0.*,>=0.11.1" "${if lark != null then "lark" else "lark-parser"}" \
      --replace "scipy==1.*,>=1.6.1" "scipy" \
      --replace "networkx==2.*,>=2.5.0" "networkx" \
      --replace "importlib-metadata==3.*,>=3.7.3" "importlib-metadata"
  '';

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
