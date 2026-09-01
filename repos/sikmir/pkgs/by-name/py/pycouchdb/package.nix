{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pycouchdb";
  version = "1.17.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "histrio";
    repo = "py-couchdb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KaY/ZotUYpaU5eWe2HC44bC1thnZ3V9AjvzQ+XMxBug=";
  };

  build-system = with python3Packages; [ hatchling ];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    requests
    chardet
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    responses
  ];

  meta = {
    description = "Modern pure python CouchDB Client";
    homepage = "https://github.com/histrio/py-couchdb";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
