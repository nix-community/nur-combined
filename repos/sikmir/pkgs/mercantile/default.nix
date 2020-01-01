{ lib, buildPythonPackage, click, pytest, mercantile }:

buildPythonPackage rec {
  pname = "mercantile";
  version = lib.substring 0 7 src.rev;
  src = mercantile;

  propagatedBuildInputs = [ click ];

  checkInputs = [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    description = mercantile.description;
    homepage = mercantile.homepage;
    license = licenses.bsd3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
