{ lib, python3Packages, sources }:

python3Packages.buildPythonPackage {
  pname = "thinplatespline";
  version = lib.substring 0 10 sources.thinplatespline.date;

  src = sources.thinplatespline;

  postPatch = ''
    2to3 -n -w tps/*.py
    substituteInPlace tps/__init__.py --replace "_tps" "._tps"
  '';

  doCheck = false;

  pythonImportsCheck = [ "tps" ];

  meta = with lib; {
    inherit (sources.thinplatespline) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
