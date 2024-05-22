{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "gpx-interpolate";
  version = "0-unstable-2023-10-28";
  format = "other";

  src = fetchFromGitHub {
    owner = "remisalmon";
    repo = "gpx-interpolate";
    rev = "00af3c636d566d049f6a140c093af4e91d0482d5";
    hash = "sha256-cCiRXpX6qj2o+vPs3V0/+UwnnHKvDFOgTbCV347BKkc=";
  };

  propagatedBuildInputs = with python3Packages; [
    gpxpy
    scipy
    numpy
  ];

  dontUseSetuptoolsBuild = true;

  checkPhase = ''
    ${python3Packages.python.interpreter} -m doctest -o IGNORE_EXCEPTION_DETAIL -f tests/tests.txt
  '';

  installPhase = ''
    sed -i '1i #!/usr/bin/env python3' gpx_interpolate.py
    install -Dm755 gpx_interpolate.py $out/bin/gpx-interpolate
  '';

  meta = with lib; {
    description = "Python script to interpolate GPX files using piecewise cubic Hermite splines";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    mainProgram = "gpx-interpolate";
  };
}
