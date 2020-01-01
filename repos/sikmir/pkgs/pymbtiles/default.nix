{ lib, buildPythonPackage, pytest, pymbtiles }:

buildPythonPackage rec {
  pname = "pymbtiles";
  version = lib.substring 0 7 src.rev;
  src = pymbtiles;

  checkInputs = [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    description = pymbtiles.description;
    homepage = pymbtiles.homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
