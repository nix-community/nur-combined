{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
}:

buildPythonPackage rec {
  pname = "protobuf-inspector";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "mildsunrise";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-zsXjNwk94SMuwlDFgOrkWTyFWFIYcrfpkbXWBk00gr0=";
  };

  dependencies = [];

  format = "setuptools";
  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "protobuf_inspector"
  ];

  meta = {
    description = "Tool to reverse-engineer Protocol Buffers with unknown definition";
    homepage = "Tool to reverse-engineer Protocol Buffers with unknown definition";
    changelog = "https://github.com/mildsunrise/protobuf-inspector/releases/tag/v${version}";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
  };
}
