{ lib, python3Packages, sources }:

python3Packages.buildPythonPackage {
  pname = "mercantile-unstable";
  version = lib.substring 0 10 sources.mercantile.date;

  src = sources.mercantile;

  propagatedBuildInputs = with python3Packages; [ click ];

  checkInputs = with python3Packages; [ pytestCheckHook hypothesis ];

  meta = with lib; {
    inherit (sources.mercantile) description homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
