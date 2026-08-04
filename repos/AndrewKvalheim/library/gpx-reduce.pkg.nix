{ fetchFromGitHub
, lib
, python3Packages
, unstableGitUpdater
}:

let
  inherit (lib) licenses;
in
python3Packages.buildPythonApplication {
  pname = "gpx-reduce";
  version = "0-unstable-2026-05-07";
  meta = {
    description = "Script that removes unnecessary points from GPX files";
    homepage = "https://github.com/Alezy80/gpx_reduce";
    license = licenses.gpl3Plus;
  };

  passthru.updateScript = unstableGitUpdater { };

  src = fetchFromGitHub {
    owner = "Alezy80";
    repo = "gpx_reduce";
    rev = "9696a3df3380b5d857ba18da56b812386ff0a09b";
    hash = "sha256-qvjS+bRrGRbClSHxiyjxU1hgCAy+Svh3pUDNLeYUKzQ=";
  };

  format = "pyproject";
  nativeBuildInputs = with python3Packages; [ setuptools ];
  dependencies = with python3Packages; [
    iso8601
    lxml
    matplotlib
    numpy
  ];

  doCheck = true;
  checkPhase = ''
    python3 'gpx_reduce.py' --help > '/dev/null'
  '';

  postInstall = ''
    install -D 'gpx_reduce.py' "$out/bin/gpx_reduce"
  '';
}
