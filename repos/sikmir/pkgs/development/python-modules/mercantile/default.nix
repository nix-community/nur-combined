{ lib, python3Packages, sources }:
let
  pname = "mercantile";
  date = lib.substring 0 10 sources.mercantile.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonPackage {
  inherit pname version;
  src = sources.mercantile;

  propagatedBuildInputs = with python3Packages; [ click ];

  checkInputs = with python3Packages; [ pytest hypothesis ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (sources.mercantile) description homepage;
    license = licenses.bsd3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
