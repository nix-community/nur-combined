{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "docx2csv";
  version = "0-unstable-2023-10-11";

  src = fetchFromGitHub {
    owner = "ivbeg";
    repo = "docx2csv";
    rev = "f0c0231876e2ab1210865ded80e4d6105816b0a3";
    hash = "sha256-A7Y1zgM+9xIDXsAQN2tGGoWbe8u/kvGch6sBNKz0Nw4=";
  };

  propagatedBuildInputs = with python3Packages; [
    click
    openpyxl
    python-docx
    xlwt
  ];

  meta = with lib; {
    description = "Extracts tables from .docx files and saves them as .csv or .xls files";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
