{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "mysql-to-sqlite3";
  version = "2.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "techouse";
    repo = "mysql-to-sqlite3";
    rev = "v${version}";
    hash = "sha256-MXOkR7eDxCtRptEYPrkmtpkxyQh/RfNAzb7MKYt8p20=";
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
  };
}
