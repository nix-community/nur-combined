{ lib, buildPythonPackage, requests, clint, sources }:
let
  pname = "mikatools";
  date = lib.substring 0 10 sources.mikatools.date;
  version = "unstable-" + date;
in
buildPythonPackage {
  inherit pname version;
  src = sources.mikatools;

  propagatedBuildInputs = [ requests clint ];

  meta = with lib; {
    inherit (sources.mikatools) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
