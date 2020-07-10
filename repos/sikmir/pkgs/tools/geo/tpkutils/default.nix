{ lib, buildPythonApplication, mercantile, pymbtiles, pytest, setuptools, six, sources }:
let
  pname = "tpkutils";
  date = lib.substring 0 10 sources.tpkutils.date;
  version = "unstable-" + date;
in
buildPythonApplication {
  inherit pname version;
  src = sources.tpkutils;

  propagatedBuildInputs = [ mercantile pymbtiles setuptools six ];

  checkInputs = [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (sources.tpkutils) description homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
