{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mysql-to-sqlite3";
  version = "2.5.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "techouse";
    repo = "mysql-to-sqlite3";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UxoPv6deWfsK5C6Y7+ecTOvPy+RPljFhatxDLP5eKq4=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    click
    mysql-connector
    python-slugify
    pytimeparse2
    simplejson
    sqlglot
    tabulate
    tqdm
    typing-extensions
  ];

  meta = {
    description = "Transfer data from MySQL to SQLite";
    homepage = "https://github.com/techouse/mysql-to-sqlite3";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mysql2sqlite";
  };
})
