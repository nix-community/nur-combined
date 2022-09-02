{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "gpx_interpolate";
  version = "2021-01-24";

  src = fetchFromGitHub {
    owner = "remisalmon";
    repo = "gpx_interpolate";
    rev = "24236e45e3d8baa0662c329b735b79a17e84c1bd";
    hash = "sha256-bN8ED3H4FXjfG9q7sIC7UmhvIFCgkbueUSFW/Q7uKD4=";
  };

  propagatedBuildInputs = with python3Packages; [ gpxpy scipy numpy ];

  dontUseSetuptoolsBuild = true;

  checkPhase = ''
    ${python3Packages.python.interpreter} -m doctest -o IGNORE_EXCEPTION_DETAIL -f test/test.txt
  '';

  installPhase = ''
    install -Dm755 gpx_interpolate.py $out/bin/gpx_interpolate
  '';

  meta = with lib; {
    description = "Python script to interpolate GPX files using linear or spline interpolation";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
