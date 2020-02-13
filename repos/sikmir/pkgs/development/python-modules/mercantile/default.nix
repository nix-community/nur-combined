{ lib, buildPythonPackage, click, pytest, sources }:

buildPythonPackage rec {
  pname = "mercantile";
  version = lib.substring 0 7 src.rev;
  src = sources.mercantile;

  propagatedBuildInputs = [ click ];

  checkInputs = [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.bsd3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
