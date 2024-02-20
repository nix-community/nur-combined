{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "camel-snake-pep8";
  version = "0.2.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "abarker";
    repo = "camel-snake-pep8";
    rev = "c328293ea8cd5875eda506f35d45ef293c9ec15f";
    hash = "sha256-0DRfObrSkOHM0c99g5yB9f8AM0XOO/QVBUAE6BFr/54=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    rope
    colorama
    setuptools # pkg_resources
  ];

  pythonImportsCheck = [ "camel_snake_pep8" ];

  meta = with lib; {
    description = "Use Rope to help convert names in a Python project to conform with PEP-8";
    homepage = "https://github.com/abarker/camel-snake-pep8";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "camel-snake-pep8";
  };
}
