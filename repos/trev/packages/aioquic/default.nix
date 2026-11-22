{
  fetchPypi,
  lib,
  nix-update-script,
  stdenv,

  # python packages
  buildPythonPackage,
  certifi,
  cryptography,
  pylsqpack-latest,
  pyopenssl,
  pytestCheckHook,
  service-identity,
  setuptools,
}:

buildPythonPackage (final: {
  pname = "aioquic";
  version = "1.9.0";
  pyproject = true;

  src = fetchPypi {
    inherit (final) pname version;
    hash = "sha256-3aqSqYN4sqOQn/xhzWLDnexpDn95k0X+AGFswONuX38=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    certifi
    cryptography
    pylsqpack-latest
    pyopenssl
    service-identity
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # QUIC needs UDP/multicast, which isn't available in the sandbox
    "test_connect_and_serve_ipv4"
  ];

  __darwinAllowLocalNetworking = true;

  pythonImportsCheck = [ "aioquic" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "${final.pname}-latest"
    ];
  };

  meta = {
    description = "Implementation of QUIC and HTTP/3";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
    homepage = "https://github.com/aiortc/aioquic";
    changelog = "https://github.com/aiortc/aioquic/blob/${final.version}/docs/changelog.rst";
    downloadPage = "https://pypi.org/project/aioquic/#files";
  };
})
