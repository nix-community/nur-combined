{
  lib,
  python3,
  fetchFromGitea,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "mygnuhealth";
  version = "2.2.0";
  pyproject = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "gnuhealth";
    repo = "mygnuhealth";
    rev = "v${version}";
    hash = "sha256-7j7r/Vj4V7aG1j2VscT+m5fsxV7NdE03ELHPAYzawdk=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    bcrypt
    bleak
    cairosvg
    cssselect
    kivy
    pygal
    python-dateutil
    requests
    tinycss
    tinydb
  ];

  pythonImportsCheck = [
    "mygnuhealth"
  ];

  meta = with lib; {
    description = "The GNU Health Personal Health Record";
    homepage = "https://codeberg.org/gnuhealth/mygnuhealth/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "mygnuhealth";
  };
}
