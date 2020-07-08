{ lib, buildPythonPackage, click, pytest, hypothesis, sources }:

buildPythonPackage {
  pname = "mercantile";
  version = lib.substring 0 7 sources.mercantile.rev;
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
