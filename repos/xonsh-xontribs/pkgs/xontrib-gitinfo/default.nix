{
  lib,
  onefetch,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  pdm-pep517,
  poetry-core,
  wheel,
}: let
  pname = "xontrib-gitinfo";
  version = "0.1.0";
in
  buildPythonPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "dyuri";
      repo = "xontrib-gitinfo";
      rev = "b1ba458d85a6684088807d962b39980144685630";
      sha256 = "sha256-e5lgfcrG8p/3YgYNlnkfZIYj3VEjuNTRoseAl+Uyfd8=";
    };

    doCheck = false;

    nativeBuildInputs = [
      setuptools
      wheel
    ];

    format = "pyproject";

    build-system = [
      setuptools
      pdm-pep517
      poetry-core
    ];

    postPatch = ''
      substituteInPlace pyproject.toml \
      --replace poetry.masonry.api poetry.core.masonry.api \
      --replace "poetry>=" "poetry-core>="
      touch xontrib/__init__.py
    '';

    dependencies = [
      onefetch
    ];

    meta = with lib; {
      homepage = "https://github.com/dyuri/xontrib-gitinfo";
      license = licenses.mit;
      # maintainers = [maintainers.drmikecrowe];
      description = "Displays git information on entering a repository folder in the [xonsh shell](https://xon.sh).";
    };
  }
