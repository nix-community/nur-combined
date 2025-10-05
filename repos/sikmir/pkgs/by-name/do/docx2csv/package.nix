{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "docx2csv";
  version = "0-unstable-2023-10-11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ivbeg";
    repo = "docx2csv";
    rev = "f0c0231876e2ab1210865ded80e4d6105816b0a3";
    hash = "sha256-A7Y1zgM+9xIDXsAQN2tGGoWbe8u/kvGch6sBNKz0Nw4=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    click
    openpyxl
    python-docx
    xlwt
  ];

  meta = {
    description = "Extracts tables from .docx files and saves them as .csv or .xls files";
    homepage = "https://github.com/ivbeg/docx2csv";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
