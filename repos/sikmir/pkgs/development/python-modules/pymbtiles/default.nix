{ lib, buildPythonPackage, pytest, sources }:

buildPythonPackage {
  pname = "pymbtiles";
  version = lib.substring 0 7 sources.pymbtiles.rev;
  src = sources.pymbtiles;

  checkInputs = [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (sources.pymbtiles) description homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
