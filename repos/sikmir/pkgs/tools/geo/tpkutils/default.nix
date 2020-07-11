{ lib, python3Packages, mercantile, pymbtiles, sources }:
let
  pname = "tpkutils";
  date = lib.substring 0 10 sources.tpkutils.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonApplication {
  inherit pname version;
  src = sources.tpkutils;

  propagatedBuildInputs = with python3Packages; [ mercantile pymbtiles setuptools six ];

  checkInputs = with python3Packages; [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (sources.tpkutils) description homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
