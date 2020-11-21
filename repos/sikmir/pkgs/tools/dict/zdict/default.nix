{ lib, python37Packages, sources }:

python37Packages.buildPythonApplication {
  pname = "zdict-unstable";
  version = lib.substring 0 10 sources.zdict.date;

  src = sources.zdict;

  propagatedBuildInputs = with python37Packages; [
    beautifulsoup4
    peewee
    requests
    setuptools
  ];

  postPatch = "sed -i 's/==.*//' requirements.txt";

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
