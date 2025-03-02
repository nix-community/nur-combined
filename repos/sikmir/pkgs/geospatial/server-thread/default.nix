{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "server-thread";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "banesullivan";
    repo = "server-thread";
    tag = version;
    hash = "sha256-1a2XFPyf3FacMx3WU1hPeiqGP4dAUGlQxsXAUz81muo=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    fastapi
    scooby
    uvicorn
    werkzeug
  ];

  nativeCheckInputs = with python3Packages; [
    flask
    requests
    pytestCheckHook
  ];

  disabledTestPaths = [ "tests/test_server.py" ];

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Launch a WSGIApplication in a background thread with werkzeug";
    homepage = "https://github.com/banesullivan/server-thread";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
