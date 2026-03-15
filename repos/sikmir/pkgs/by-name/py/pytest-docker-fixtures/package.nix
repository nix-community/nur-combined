{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pytest-docker-fixtures";
  version = "1.4.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "guillotinaweb";
    repo = "pytest-docker-fixtures";
    tag = finalAttrs.version;
    hash = "sha256-G4kij7xqulosUkU8XzseoMN0yXykMrsgnJYLmH+MrUw=";
  };

  build-system = with python3Packages; [ setuptools ];

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
})
