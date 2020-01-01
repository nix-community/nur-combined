{ lib, buildPythonApplication, nose, mbutil }:

buildPythonApplication rec {
  pname = "mbutil";
  version = lib.substring 0 7 src.rev;
  src = mbutil;

  checkInputs = [ nose ];
  checkPhase = "nosetests";

  meta = with lib; {
    description = mbutil.description;
    homepage = mbutil.homepage;
    license = licenses.bsd3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
