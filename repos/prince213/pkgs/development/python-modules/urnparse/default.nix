{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  typing-extensions,

  # nativeCheckInputs
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "urnparse";
  version = "0.2.2";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "oarepo";
    repo = "urnparse";
    tag = finalAttrs.version;
    hash = "sha256-/2VS+UEkmuJS+G3O/vuWCPw5cJWy2/kSlT+HS5J6Fz8=";
  };

  postPatch = ''
    sed -i '/pytest-runner/d' setup.py
  '';

  build-system = [ setuptools ];

  dependencies = [ typing-extensions ];

  pythonImportsCheck = [ "urnparse" ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    description = "Library for generating and parsing RFC 8141 compliant uniform resource names";
    homepage = "https://github.com/oarepo/urnparse";
    downloadPage = "https://github.com/oarepo/urnparse/releases";
    changelog = "https://github.com/oarepo/urnparse/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
