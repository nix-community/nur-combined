{ lib, python3Packages, s2sphere, sources }:

python3Packages.buildPythonApplication {
  pname = "py-staticmaps-unstable";
  version = lib.substring 0 10 sources.py-staticmaps.date;

  src = sources.py-staticmaps;

  propagatedBuildInputs = with python3Packages; [ appdirs geographiclib pillow pycairo python-slugify requests s2sphere svgwrite ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    inherit (sources.py-staticmaps) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
