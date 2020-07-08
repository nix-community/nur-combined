{ lib, buildPythonApplication, matplotlib, nose, sounddevice, sources }:

buildPythonApplication {
  pname = "morse-talk";
  version = lib.substring 0 7 sources.morse-talk.rev;
  src = sources.morse-talk;

  propagatedBuildInputs = [ matplotlib sounddevice ];

  checkInputs = [ nose ];
  checkPhase = "nosetests";

  meta = with lib; {
    inherit (sources.morse-talk) description homepage;
    license = licenses.gpl2;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
