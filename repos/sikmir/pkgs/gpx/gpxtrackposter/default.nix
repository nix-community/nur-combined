{ lib, fetchFromGitHub, python3Packages, s2sphere }:

python3Packages.buildPythonApplication rec {
  pname = "gpxtrackposter";
  version = "2021-12-01";

  src = fetchFromGitHub {
    owner = "flopp";
    repo = pname;
    rev = "d7ff0ba61f6396938efd075d841a7c4a226a6f5d";
    hash = "sha256-J1CZ2wrL8Myd++skUOyyXLDPyRpOsBWEGxzqhk7OKqU=";
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

  checkInputs = with python3Packages; [
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
