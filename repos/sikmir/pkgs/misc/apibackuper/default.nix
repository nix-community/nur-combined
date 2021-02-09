{ lib, python3Packages, bson, sources }:

python3Packages.buildPythonApplication {
  pname = "apibackuper-unstable";
  version = lib.substring 0 10 sources.apibackuper.date;

  src = sources.apibackuper;

  propagatedBuildInputs = with python3Packages; [ bson click lxml requests xmltodict ];

  doCheck = false;

  meta = with lib; {
    inherit (sources.apibackuper) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
