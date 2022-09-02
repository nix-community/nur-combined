{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "docx2csv";
  version = "2020-05-06";

  src = fetchFromGitHub {
    owner = "ivbeg";
    repo = "docx2csv";
    rev = "e397b6bd17c73d76b21404ce3422496b8da262db";
    hash = "sha256-7l8gWzwhIScWixzm+mRLntfilEgG7cZOvFhhiRhPEFg=";
  };

  propagatedBuildInputs = with python3Packages; [ click openpyxl python-docx xlwt ];

  meta = with lib; {
    description = "Extracts tables from .docx files and saves them as .csv or .xls files";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
