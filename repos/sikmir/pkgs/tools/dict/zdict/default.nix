{ lib, python37Packages, sources }:
let
  pname = "zdict";
  date = lib.substring 0 10 sources.zdict.date;
  version = "unstable-" + date;
in
python37Packages.buildPythonApplication {
  inherit pname version;
  src = sources.zdict;

  propagatedBuildInputs = with python37Packages; [
    beautifulsoup4
    peewee
    requests
    setuptools
  ];

  buildPhase = ''
    ${python37Packages.python.interpreter} setup.py build
  '';

  doCheck = false;

  installPhase = ''
    ${python37Packages.python.interpreter} setup.py install --skip-build --prefix=$out
  '';

  meta = with lib; {
    inherit (sources.zdict) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
