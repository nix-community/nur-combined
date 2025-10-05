{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication {
  pname = "py-osm-static-maps";
  version = "0-unstable-2024-10-16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "NHellFire";
    repo = "py-osm-static-maps";
    rev = "0ef9cee293f0b1aeb64838da186076f35cebc16d";
    hash = "sha256-5+7hPRzryiH9fC2cY+/IDZAAxGw2wYZvSR9V+EjVN1I=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    flask
    pillow
    requests
    selenium
    setuptools
  ];

  meta = {
    description = "Python rewrite of jperelli/osm-static-maps";
    homepage = "https://github.com/NHellFire/py-osm-static-maps";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "osmsm";
  };
}
