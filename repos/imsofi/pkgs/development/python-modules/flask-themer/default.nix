{ lib
, buildPythonPackage
, fetchFromGitHub
, flask
, pytestCheckHook
, pytest-cov
}:

buildPythonPackage rec {
  pname = "flask-themer";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "TkTech";
    repo = "flask-themer";
    rev = "v${version}";
    sha256 = "sha256-K2y0Ivy5eb8BV8Lb49Fng2X3gkF1jXbQus5lzhfd4bk=";
  };

  propagatedBuildInputs = [
    flask
  ];

  checkInputs = [
    pytestCheckHook
    pytest-cov
  ];

  pythonImportsCheck = [ "flask_themer" ];

  meta = with lib; {
    description = "Simple theming support for Flask apps.";
    homepage = "https://github.com/TkTech/flask-themer";
    license = licenses.mit;
    maintainers = with maintainers; [ imsofi ];
  };
}
