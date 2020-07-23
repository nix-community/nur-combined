{ lib, python3Packages, sources }:
let
  pname = "cheetah3";
  date = lib.substring 0 10 sources.cheetah3.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonPackage {
  inherit pname version;
  src = sources.cheetah3;

  checkInputs = with python3Packages; [ pygments markdown ];

  checkPhase = ''
    ${python3Packages.python.interpreter} Cheetah/Tests/Test.py
  '';

  doCheck = false;

  meta = with lib; {
    inherit (sources.cheetah3) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
