{ lib, buildPythonPackage, sources }:

buildPythonPackage {
  pname = "cheetah3";
  version = lib.substring 0 7 sources.cheetah3.rev;
  src = sources.cheetah3;

  doCheck = false;

  meta = with lib; {
    inherit (sources.cheetah3) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
