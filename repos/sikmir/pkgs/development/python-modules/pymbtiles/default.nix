{ lib, buildPythonPackage, pytest, sources }:

buildPythonPackage rec {
  pname = "pymbtiles";
  version = lib.substring 0 7 src.rev;
  src = sources.pymbtiles;

  checkInputs = [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
