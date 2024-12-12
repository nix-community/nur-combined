{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "pycouchdb";
  version = "1.16.0";
  pyproject = true;
  disabled = python3Packages.pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "histrio";
    repo = "py-couchdb";
    tag = "v${version}";
    hash = "sha256-jcDES8PC02F5eel2KThYZFXKzUm70UqktG521lt+Dj0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "poetry.masonry" "poetry.core.masonry" \
      --replace-fail "poetry>=" "poetry-core>="
  '';

  build-system = with python3Packages; [ poetry-core ];

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
}
