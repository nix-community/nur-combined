{ lib, python3Packages, mercantile, pymbtiles, sources }:

python3Packages.buildPythonApplication {
  pname = "tpkutils-unstable";
  version = lib.substring 0 10 sources.tpkutils.date;

  src = sources.tpkutils;

  propagatedBuildInputs = with python3Packages; [ mercantile pymbtiles setuptools six ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    inherit (sources.tpkutils) description homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
