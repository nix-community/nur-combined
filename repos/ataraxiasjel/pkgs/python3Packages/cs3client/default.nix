{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
  setuptools,
  cryptography,
  cs3apis,
  grpcio,
  grpcio-tools,
  protobuf,
  pyjwt,
  pyopenssl,
  requests,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "cs3client";
  version = "1.7.1";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gd7/sherjmbdGZtyN3qdBXiximukchMpuzYpb1waGGw=";
  };

  PACKAGE_VERSION = version;

  build-system = [ setuptools ];

  dependencies = [
    cryptography
    cs3apis
    grpcio
    grpcio-tools
    protobuf
    pyjwt
    pyopenssl
    requests
  ];

  # FIXME: tests
  # nativeCheckInputs = [
  #   pytestCheckHook
  # ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://github.com/cs3org/cs3-python-client";
    description = "Python client for interacting with the CS3 API";
    license = licenses.asl20;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
