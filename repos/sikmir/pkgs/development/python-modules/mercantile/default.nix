{ lib, buildPythonPackage, click, pytest, hypothesis, sources }:
let
  pname = "mercantile";
  date = lib.substring 0 10 sources.mercantile.date;
  version = "unstable-" + date;
in
buildPythonPackage {
  inherit pname version;
  src = sources.mercantile;

  propagatedBuildInputs = [ click ];

  checkInputs = [ pytest hypothesis ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (sources.mercantile) description homepage;
    license = licenses.bsd3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
