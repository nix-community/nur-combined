{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "flask";
  version = "2.3.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pallets";
    repo = "flask";
    rev = version;
    hash = "sha256-hxEPWLGoKQSmjocogDdLz3hIvT/GQ/V4+BZ55jIxlE8=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    blinker
    click
    importlib-metadata
    itsdangerous
    jinja2
    werkzeug
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    async = [
      asgiref
    ];
    dotenv = [
      python-dotenv
    ];
  };

  pythonImportsCheck = [ "flask" ];

  meta = with lib; {
    description = "The Python micro framework for building web applications";
    homepage = "https://github.com/pallets/flask";
    changelog = "https://github.com/pallets/flask/blob/${src.rev}/CHANGES.rst";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
