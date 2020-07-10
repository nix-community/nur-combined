{ lib, buildPythonPackage, sources }:
let
  pname = "cheetah3";
  date = lib.substring 0 10 sources.cheetah3.date;
  version = "unstable-" + date;
in
buildPythonPackage {
  inherit pname version;
  src = sources.cheetah3;

  doCheck = false;

  meta = with lib; {
    inherit (sources.cheetah3) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
