{ lib, python3Packages, s2sphere, sources }:
let
  pname = "gpxtrackposter";
  date = lib.substring 0 10 sources.gpxtrackposter.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonApplication {
  inherit pname version;
  src = sources.gpxtrackposter;

  postPatch = ''
    substituteInPlace gpxtrackposter/poster.py \
      --replace "ATHLETE" ""
  '';

  propagatedBuildInputs = with python3Packages; [ appdirs gpxpy svgwrite colour s2sphere ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    inherit (sources.gpxtrackposter) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
