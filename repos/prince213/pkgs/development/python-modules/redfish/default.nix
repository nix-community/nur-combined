{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  aiohttp,
  jsonpatch,
  jsonpath-ng,
  jsonpointer,
  multidict,
  requests,
  requests-toolbelt,
  requests-unixsocket,
  urllib3,
  yarl,

  # nativeCheckInputs
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "redfish";
  version = "3.3.9";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "DMTF";
    repo = "python-redfish-library";
    tag = finalAttrs.version;
    hash = "sha256-c50+QALePV30Dr5LOfGvCRqW9Oqdqj/qyNQPiqwK+hY=";
  };

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    jsonpatch
    jsonpath-ng
    jsonpointer
    multidict
    requests
    requests-toolbelt
    requests-unixsocket
    urllib3
    yarl
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
