{ lib, buildPythonApplication, nose, mbutil }:

buildPythonApplication rec {
  pname = "mbutil";
  version = lib.substring 0 7 src.rev;
  src = mbutil;

  checkInputs = [ nose ];
  checkPhase = "nosetests";

  meta = with lib; {
    description = mbutil.description;
    homepage = "https://github.com/mapbox/mbutil";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sikmir ];
  };
}
