{ lib, buildPythonPackage, requests, clint, sources }:

buildPythonPackage {
  pname = "mikatools";
  version = lib.substring 0 7 sources.mikatools.rev;
  src = sources.mikatools;

  propagatedBuildInputs = [ requests clint ];

  meta = with lib; {
    inherit (sources.mikatools) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
