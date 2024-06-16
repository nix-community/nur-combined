{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "server-thread";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "banesullivan";
    repo = "server-thread";
    rev = version;
    hash = "sha256-/ddMaXIIl9GC9RCZ3JuPL5pX8YQuPCCfjHg3i5ecWDY=";
  };

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

  meta = {
    description = "Launch a WSGIApplication in a background thread with werkzeug";
    homepage = "https://github.com/banesullivan/server-thread";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
