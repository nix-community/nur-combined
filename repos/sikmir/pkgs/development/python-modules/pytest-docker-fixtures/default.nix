{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pytest-docker-fixtures";
  version = "1.3.19";

  src = fetchFromGitHub {
    owner = "guillotinaweb";
    repo = "pytest-docker-fixtures";
    tag = version;
    hash = "sha256-9MR2gz69/oGNjuZNGTSe58j8ykOl6AWWII+XzLkri60=";
  };

  dependencies = with python3Packages; [
    docker
    pytest
    requests
  ];

  doCheck = false;

  meta = {
    description = "Pytest docker fixtures";
    homepage = "https://github.com/guillotinaweb/pytest-docker-fixtures";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
