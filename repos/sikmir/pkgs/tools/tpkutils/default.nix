{ lib, buildPythonApplication, mercantile, pymbtiles, pytest, setuptools, six, sources }:

buildPythonApplication rec {
  pname = "tpkutils";
  version = lib.substring 0 7 src.rev;
  src = sources.tpkutils;

  propagatedBuildInputs = [ mercantile pymbtiles setuptools six ];

  checkInputs = [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
