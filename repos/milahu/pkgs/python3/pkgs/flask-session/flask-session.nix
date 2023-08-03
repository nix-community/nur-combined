{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "flask-session";
  version = "0.5.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pallets-eco";
    repo = "flask-session";
    rev = version;
    hash = "sha256-t8w6ZS4gBDpnnKvL3DLtn+rRLQNJbrT2Hxm4f3+a3Xc=";
  };

  nativeBuildInputs = [
    python3.pkgs.flit-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    cachelib
    flask
  ];

  pythonImportsCheck = [ "flask_session" ];

  meta = with lib; {
    description = "Server side session extension for Flask";
    homepage = "https://github.com/pallets-eco/flask-session";
    changelog = "https://github.com/pallets-eco/flask-session/blob/${src.rev}/CHANGES.rst";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
