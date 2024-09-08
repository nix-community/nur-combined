{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication {
  pname = "py-osm-static-maps";
  version = "0-unstable-2023-09-23";

  src = fetchFromGitHub {
    owner = "NHellFire";
    repo = "py-osm-static-maps";
    rev = "8c78104781467adf3432dd2b3a659f47b6bc8c2e";
    hash = "sha256-6/Sd1owLiEUGY7hcmGQKJnL5RRhCsRjdAWK2HV4TXVg=";
  };

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
