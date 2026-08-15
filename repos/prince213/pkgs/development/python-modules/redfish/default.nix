{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  jsonpatch,
  jsonpath-ng,
  jsonpointer,
  requests,
  requests-toolbelt,
  requests-unixsocket,
  urllib3,

  # nativeCheckInputs
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "redfish";
  version = "3.3.8";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "DMTF";
    repo = "python-redfish-library";
    tag = finalAttrs.version;
    hash = "sha256-b+cIvJSoqhzncvchH63lG4k3p7ks+lrmF0GikYBT0eM=";
  };

  build-system = [ setuptools ];

  dependencies = [
    jsonpatch
    jsonpath-ng
    jsonpointer
    requests
    requests-toolbelt
    requests-unixsocket
    urllib3
  ]
  ++ urllib3.optional-dependencies.zstd;

  pythonImportsCheck = [ "redfish" ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    description = "Library for interacting with devices that support a Redfish service";
    homepage = "https://github.com/DMTF/python-redfish-library";
    downloadPage = "https://github.com/DMTF/python-redfish-library/releases";
    changelog = "https://github.com/DMTF/python-redfish-library/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
