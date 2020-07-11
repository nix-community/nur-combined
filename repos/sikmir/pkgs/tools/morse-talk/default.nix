{ lib, python3Packages, sources }:
let
  pname = "morse-talk";
  date = lib.substring 0 10 sources.morse-talk.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonApplication {
  inherit pname version;
  src = sources.morse-talk;

  propagatedBuildInputs = with python3Packages; [ matplotlib sounddevice tkinter ];

  checkInputs = with python3Packages; [ nose ];
  checkPhase = "nosetests";

  meta = with lib; {
    inherit (sources.morse-talk) description homepage;
    license = licenses.gpl2;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
