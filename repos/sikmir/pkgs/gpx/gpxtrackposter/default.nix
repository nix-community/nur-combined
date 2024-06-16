{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
  s2sphere,
}:

python3Packages.buildPythonApplication {
  pname = "gpxtrackposter";
  version = "0-unstable-2023-02-19";

  src = fetchFromGitHub {
    owner = "flopp";
    repo = "GpxTrackPoster";
    rev = "0b86e7223eaeea3e168f5b68ee7b8fe4ca8532b5";
    hash = "sha256-pSMfHNpGt68Elgi4NGrBlnZxpsuS7WhqM6kBDcihLu8=";
  };

  patches = [
    # Fix TimezoneAdjuster
    (fetchpatch {
      url = "https://github.com/flopp/GpxTrackPoster/commit/4ccfbe89ae49cbac18b773d2cada2c75aead67b1.patch";
      hash = "sha256-1nnZZO4KipT/mDwBLZgrbpE1HbwGOGbYM9D5cnmp8zY=";
    })
    ./fix-localedir.patch
  ];

  postPatch = ''
    substituteInPlace gpxtrackposter/poster.py \
      --replace-fail "self.translate(\"ATHLETE\")" "\"\""
    substituteInPlace gpxtrackposter/cli.py \
      --subst-var out
    sed -i 's/~=.*//' requirements.txt
  '';

  dependencies = with python3Packages; [
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

  nativeCheckInputs = with python3Packages; [
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

  meta = {
    description = "Create a visually appealing poster from your GPX tracks";
    homepage = "https://github.com/flopp/GpxTrackPoster";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true; # https://github.com/stravalib/stravalib/pull/459
  };
}
