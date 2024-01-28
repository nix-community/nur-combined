{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "mysql-to-sqlite3";
  version = "2.1.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "techouse";
    repo = "mysql-to-sqlite3";
    rev = "v${version}";
    hash = "sha256-nS+BWVemB1XYe37+Cl8q8ZhXBcZDBw5ApOapns7hXKg=";
  };

  nativeBuildInputs = with python3Packages; [ hatchling ];

  propagatedBuildInputs = with python3Packages; [
    click
    mysql-connector
    python-slugify
    pytimeparse2
    simplejson
    tabulate
    tqdm
    typing-extensions
  ];

  meta = with lib; {
    description = "Transfer data from MySQL to SQLite";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    mainProgram = "mysql2sqlite";
    broken = true; # required mysql-connector-python>=8.2.0
  };
}
