{ lib, buildPythonApplication, matplotlib, nose, sounddevice, sources }:
let
  pname = "morse-talk";
  date = lib.substring 0 10 sources.morse-talk.date;
  version = "unstable-" + date;
in
buildPythonApplication {
  inherit pname version;
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
