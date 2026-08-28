{
  buildPythonPackage,
  lib,
  six,
  fetchPypi,
  pyyaml,
  mock,
  contextlib2,
  wrapt,
  pytest,
  pytest-httpbin,
  yarl,
  pythonOlder,
  pythonAtLeast,
}:

buildPythonPackage (finalAttrs: {
  pname = "vcrpy";
  version = "3.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-IRaNWuFCY6gz1Lcaz9gnjYhBEU8kvhtKtKVxnQx/B7w=";
  };

  checkInputs = [
    pytest
    pytest-httpbin
  ];

  propagatedBuildInputs = [
    pyyaml
    wrapt
    six
  ]
  ++ lib.optionals (pythonOlder "3.3") [
    contextlib2
    mock
  ]
  ++ lib.optionals (pythonAtLeast "3.4") [ yarl ];

  checkPhase = ''
    py.test --ignore=tests/integration -k "not TestVCRConnection"
  '';

  meta = with lib; {
    description = "Automatically mock your HTTP interactions to simplify and speed up testing";
    homepage = "https://github.com/kevin1024/vcrpy";
    license = licenses.mit;
  };
})
