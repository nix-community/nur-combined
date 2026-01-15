{
  lib,
  fetchFromGitHub,
  python312Packages,
  s2sphere,
  unstableGitUpdater,
}:

python312Packages.buildPythonApplication {
  pname = "gpxtrackposter";
  version = "0-unstable-2024-06-02";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "flopp";
    repo = "GpxTrackPoster";
    rev = "1ca04e9f2fb4a5ee33e2fb0863e6169ecb2c99a0";
    hash = "sha256-0Bdls3Pe1K/3QSK9vsfcIxr3arB4/PZ+IsQO5Pk180E=";
  };

  patches = [
    ./fix-localedir.patch
  ];

  postPatch = ''
    substituteInPlace gpxtrackposter/poster.py \
      --replace-fail "self.translate(\"ATHLETE\")" "\"\""

    # https://github.com/flopp/GpxTrackPoster/issues/115
    substituteInPlace gpxtrackposter/track.py \
      --replace-fail "from stravalib.model import Activity" "from stravalib.model import DetailedActivity"

    # https://github.com/flopp/GpxTrackPoster/issues/102
    substituteInPlace gpxtrackposter/timezone_adjuster.py \
      --replace-fail "__init__(self)" "__new__(cls)" \
      --replace-fail "TimezoneAdjuster._timezonefinder" "cls._timezonefinder"

    substituteInPlace gpxtrackposter/cli.py \
      --subst-var out
  '';

  build-system = with python312Packages; [ setuptools ];

  dependencies = with python312Packages; [
    appdirs
    colour
    geopy
    gpxpy
    pint
    pytz
    s2sphere
    svgwrite
    stravalib
    polyline
    timezonefinder
    setuptools
  ];

  pythonRelaxDeps = [ "stravalib" ];

  nativeCheckInputs = with python312Packages; [
    pytestCheckHook
    (pytest-mock.overrideAttrs (old: rec {
      pname = "pytest-mock";
      version = "3.3.1";
      src = fetchPypi {
        inherit pname version;
        hash = "sha256-pNbTcynkqJPnfZ/6ieg43StF1dwJmYTPA8cDrIQRu4I=";
      };
    }))
  ];

  doCheck = false;

  postInstall = "rm -fr $out/requirements*.txt";

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Create a visually appealing poster from your GPX tracks";
    homepage = "https://github.com/flopp/GpxTrackPoster";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "create_poster";
  };
}
