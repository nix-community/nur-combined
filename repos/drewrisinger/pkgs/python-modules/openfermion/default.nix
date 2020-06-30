{ lib
, buildPythonPackage
, fetchFromGitHub
, h5py
, networkx
, numpy
, pubchempy
, requests
, scipy
  # test inputs
, pytestCheckHook
, nbformat
}:

buildPythonPackage rec {
  pname = "openfermion";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "openfermion";
    rev = "v${version}";
    sha256 = "1i6cszzmfbcg43xfk1g87m78s8wzyh3fcwk54lbwry1mxcpcgx7y";
  };

  propagatedBuildInputs = [
    h5py
    networkx
    numpy
    pubchempy
    requests
    scipy
  ];

  pythonImportsCheck = [ "openfermion" ];
  dontUseSetuptoolsCheck = true;
  checkInputs = [ pytestCheckHook nbformat ];

  # For NixOS 19.09, run tests from source dir
  preCheck = "pushd $TMP/$sourceRoot";
  postCheck = "pushd $TMP/$sourceRoot";

  pytestFlagsArray = [
    "--disable-warnings"  # for reducing output so Travis CI isn't angry
  ];
  disabledTests = [
    "OpenFermionPubChemTest"
    "test_can_run_examples_jupyter_notebooks"
    "test_signal" # Fails when built on WSL, 1e-5 error in one value
  ];

  meta = with lib; {
    description = "The electronic structure package for quantum computers.";
    homepage = "https://github.com/quantumlib/openfermion";
    license = licenses.asl20;
    # maintainers = with maintainers; [ drewrisinger ];
  };
}
