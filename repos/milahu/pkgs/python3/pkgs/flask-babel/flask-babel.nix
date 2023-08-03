{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "flask-babel";
  version = "3.1.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "python-babel";
    repo = "flask-babel";
    rev = "v${version}";
    hash = "sha256-KoTHBrGD6M3rkXoxUadRXhroRUbWKaL/rE6Rd2mxw4c=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    babel
    flask
    jinja2
    pytz
  ];

  pythonImportsCheck = [ "flask_babel" ];

  meta = with lib; {
    description = "I18n and l10n support for Flask based on Babel and pytz";
    homepage = "https://github.com/python-babel/flask-babel";
    changelog = "https://github.com/python-babel/flask-babel/blob/${src.rev}/CHANGELOG";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
