{ lib
, buildPythonPackage
, fetchFromGitHub
, hypothesis
, py-multibase
, py-multicodec
, py-multihash
, pytestCheckHook
, pytest-runner
, setuptools
}:

buildPythonPackage rec {
  pname = "py-multiformats-cid";
  version = "unstable-2022-11-23";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "pinnaculum";
    repo = "py-multiformats-cid";
    rev = "7564c28ef0b2d9bb0b2cba7398e2e4da3cf0084a";
    hash = "sha256-cg/8gYeM+GvQ3oqzSFamx+q6yWTxycmo3gCR3noQrCM=";
  };

  propagatedBuildInputs = [
    py-multihash
    py-multibase
    py-multicodec
  ];

  checkInputs = [
    pytestCheckHook
    hypothesis
    pytest-runner
  ];

  pythonImportsCheck = [ "multiformats_cid" ];

  meta = with lib; {
    description = "Self-describing content-addressed identifiers for distributed systems implementation in Python (fork of the deprecated ipld/py-cid";
    homepage = "https://github.com/pinnaculum/py-multiformats-cid";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
