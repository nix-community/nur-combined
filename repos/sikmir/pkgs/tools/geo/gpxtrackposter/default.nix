{ lib, python3Packages, s2sphere, sources }:
let
  pname = "gpxtrackposter";
  date = lib.substring 0 10 sources.gpxtrackposter.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonApplication {
  inherit pname version;
  src = sources.gpxtrackposter;

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

  checkInputs = with python3Packages; [ pytestCheckHook ];

  postInstall = ''
    rm -fr $out/requirements*.txt
  '';

  meta = with lib; {
    inherit (sources.gpxtrackposter) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
