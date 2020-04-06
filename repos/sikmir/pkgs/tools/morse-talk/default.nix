{ lib, buildPythonApplication, matplotlib, nose, sounddevice, sources }:

buildPythonApplication rec {
  pname = "morse-talk";
  version = lib.substring 0 7 src.rev;
  src = sources.morse-talk;

  propagatedBuildInputs = [ matplotlib sounddevice ];

  checkInputs = [ nose ];
  checkPhase = "nosetests";

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.gpl2;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
