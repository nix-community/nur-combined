{ lib, python3Packages, sources }:

python3Packages.buildPythonApplication {
  pname = "gpx_interpolate";
  version = lib.substring 0 10 sources.gpx-interpolate.date;

  src = sources.gpx-interpolate;

  propagatedBuildInputs = with python3Packages; [ gpxpy scipy numpy ];

  dontUseSetuptoolsBuild = true;

  checkPhase = ''
    ${python3Packages.python.interpreter} -m doctest -o IGNORE_EXCEPTION_DETAIL -f test/test.txt
  '';

  installPhase = ''
    install -Dm755 gpx_interpolate.py $out/bin/gpx_interpolate
  '';

  meta = with lib; {
    inherit (sources.gpx-interpolate) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
