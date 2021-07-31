{ lib, fetchFromGitHub, python3Packages, s2sphere }:

python3Packages.buildPythonApplication rec {
  pname = "gpxtrackposter";
  version = "2021-05-01";

  src = fetchFromGitHub {
    owner = "flopp";
    repo = pname;
    rev = "0b13e79c2332856ee35aa88921c168d717b33f87";
    hash = "sha256-0VXSes/Q6XD5/tevZihPAgOIwfYit4c3dJbIPugAWM0=";
  };

  patches = [ ./fix-localedir.patch ];

  postPatch = ''
    substituteInPlace gpxtrackposter/poster.py \
      --replace "self.translate(\"ATHLETE\")" "\"\""
    substituteInPlace gpxtrackposter/cli.py \
      --subst-var out
  '';

  propagatedBuildInputs = with python3Packages; [
    appdirs
    dateutil
    gpxpy
    svgwrite
    colour
    s2sphere
    pint
    polyline
    pytz
    setuptools
    stravalib
    timezonefinder
  ];

  checkInputs = with python3Packages; [
    pytestCheckHook
    (pytest-mock.overrideAttrs (old: rec {
      pname = "pytest-mock";
      version = "3.3.1";
      src = fetchPypi {
        inherit pname version;
        sha256 = "10mv262aq0y70g7q9689vkalaayx73l8kylzgpkr7a7455rx7mm4";
      };
    }))
  ];

  postInstall = "rm -fr $out/requirements*.txt";

  meta = with lib; {
    description = "Create a visually appealing poster from your GPX tracks";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
