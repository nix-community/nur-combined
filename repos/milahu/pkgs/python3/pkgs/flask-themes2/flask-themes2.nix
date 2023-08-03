{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonApplication rec {
  pname = "flask-themes2";
  version = "1.0.0";
  format = "setuptools";

  src = fetchPypi {
    pname = "Flask-Themes2";
    inherit version;
    hash = "sha256-0U0cSdBddb9+IG3CU6zUPlxaJhQlxOV6OLgxnNDChy8=";
  };

  checkInputs = with python3.pkgs; [
    pytest
  ];

  propagatedBuildInputs = with python3.pkgs; [
    flask
  ];

  pythonImportsCheck = [ "flask_themes2" ];

  meta = with lib; {
    description = "Provides infrastructure for theming Flask applications";
    homepage = "https://pypi.org/project/Flask-Themes2/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
