{ lib, python3Packages, sources }:

python3Packages.buildPythonApplication {
  pname = "docx2csv-unstable";
  version = lib.substring 0 10 sources.docx2csv.date;

  src = sources.docx2csv;

  propagatedBuildInputs = with python3Packages; [ click openpyxl python-docx xlwt ];

  meta = with lib; {
    inherit (sources.docx2csv) description homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
