{ lib, python3Packages, sources }:
let
  pname = "mikatools";
  date = lib.substring 0 10 sources.mikatools.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonPackage {
  inherit pname version;
  src = sources.mikatools;

  propagatedBuildInputs = with python3Packages; [ requests clint ];

  meta = with lib; {
    inherit (sources.mikatools) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
