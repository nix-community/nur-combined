{ lib, python3Packages, sources }:

python3Packages.buildPythonApplication {
  pname = "morse-talk-unstable";
  version = lib.substring 0 10 sources.morse-talk.date;

  src = sources.morse-talk;

  propagatedBuildInputs = with python3Packages; [ matplotlib sounddevice tkinter ];

  checkInputs = with python3Packages; [ nose ];
  checkPhase = "nosetests";

  meta = with lib; {
    inherit (sources.morse-talk) description homepage;
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
