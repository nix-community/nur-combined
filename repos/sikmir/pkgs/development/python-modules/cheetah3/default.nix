{ lib, buildPythonPackage, sources }:

buildPythonPackage rec {
  pname = "cheetah3";
  version = lib.substring 0 7 src.rev;
  src = sources.cheetah3;

  doCheck = false;

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
