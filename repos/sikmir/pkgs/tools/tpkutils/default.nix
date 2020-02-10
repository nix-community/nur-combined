{ lib, buildPythonApplication, mercantile, pymbtiles, pytest, setuptools, six, tpkutils }:

buildPythonApplication rec {
  pname = "tpkutils";
  version = lib.substring 0 7 src.rev;
  src = tpkutils;

  propagatedBuildInputs = [ mercantile pymbtiles setuptools six ];

  checkInputs = [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    description = tpkutils.description;
    homepage = tpkutils.homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
