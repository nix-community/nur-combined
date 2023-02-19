{ lib, fetchFromGitHub, fetchpatch, python3Packages, s2sphere }:

python3Packages.buildPythonApplication rec {
  pname = "gpxtrackposter";
  version = "2022-12-28";

  src = fetchFromGitHub {
    owner = "flopp";
    repo = "gpxtrackposter";
    rev = "e872069af0a713a479608a4a5a7987570e3bc206";
    hash = "sha256-7eJVVJIseQabSVBVogqGmKepRseWCzQvOhNfbfGvbCM=";
  };

  patches = [
    (fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/flopp/GpxTrackPoster/pull/108.patch";
      hash = "sha256-9h6ymt9z0OUFNwQq4hGCTmT389ulbBzSYJ7r2k4mO4U=";
    })
    ./fix-localedir.patch
  ];

  postPatch = ''
    substituteInPlace gpxtrackposter/poster.py \
      --replace "self.translate(\"ATHLETE\")" "\"\""
    substituteInPlace gpxtrackposter/cli.py \
      --subst-var out
    sed -i 's/~=.*//' requirements.txt
  '';

  propagatedBuildInputs = with python3Packages; [
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

  meta = with lib; {
    description = "Create a visually appealing poster from your GPX tracks";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
