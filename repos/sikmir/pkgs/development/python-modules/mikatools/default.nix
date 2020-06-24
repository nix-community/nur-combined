{ lib, buildPythonPackage, requests, clint, sources }:

buildPythonPackage rec {
  pname = "mikatools";
  version = lib.substring 0 7 src.rev;
  src = sources.mikatools;

  propagatedBuildInputs = [ requests clint ];

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
