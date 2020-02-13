{ lib, buildPythonApplication, nose, sources }:

buildPythonApplication rec {
  pname = "mbutil";
  version = lib.substring 0 7 src.rev;
  src = sources.mbutil;

  checkInputs = [ nose ];
  checkPhase = "nosetests";

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.bsd3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
