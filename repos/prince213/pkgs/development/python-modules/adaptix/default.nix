{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonAtLeast,

  # build-system
  uv-build,

  # nativeCheckInputs
  pytestCheckHook,
  dirty-equals,
  phonenumberslite,
}:

buildPythonPackage (finalAttrs: {
  pname = "adaptix";
  version = "3.0.0b12";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "reagento";
    repo = "adaptix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-daW0yRweGf33EsiSOusKWOB8bw0kbSkWfyMuKUZet5s=";
  };

  patches = [ ./build-system.patch ];

  build-system = [ uv-build ];

  pythonImportsCheck = [ "adaptix" ];

  nativeCheckInputs = [
    pytestCheckHook
    dirty-equals
    phonenumberslite
  ];

  preCheck = ''
    export PYTHONPATH="tests/tests_helpers:$PYTHONPATH"
  '';

  disabledTestPaths = lib.optionals (pythonAtLeast "3.13") [
    "tests/unit/type_tools/test_normalize_type.py::test_forward_ref_at_type_var_limit"
  ];

  meta = {
    description = "Data model conversion library";
    homepage = "https://github.com/reagento/adaptix";
    downloadPage = "https://github.com/reagento/adaptix/releases";
    changelog = "https://adaptix.readthedocs.io/en/latest/reference/changelog.html";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
