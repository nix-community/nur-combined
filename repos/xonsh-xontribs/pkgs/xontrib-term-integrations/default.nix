{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  poetry-core,
  pdm-pep517,
  lib,
}: let
  pname = "xontrib-term-integrations";
  version = "0.2.0-alpha1";
in
  buildPythonPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "jnoortheen";
      repo = "xontrib-term-integrations";
      rev = "c1cf9a8aa72683548e32b59045917c1c8c760fa8";
      sha256 = "sha256-pO4rx4vB2qZwFXtCfwNknLhLhkVBxxOb1hVgICnsVUo=";
    };

    doCheck = false;

    nativeBuildInputs = [
      setuptools
      wheel
      poetry-core
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
      sed -ie "/xonsh.*=/d" pyproject.toml
    '';

    meta = with lib; {
      homepage = "https://github.com/jnoortheen/xontrib-term-integrations";
      license = licenses.mit;
      # maintainers = [maintainers.drmikecrowe];
      description = "Support shell integration of terminal programs iTerm2, Kitty, etc in the [xonsh shell](https://xon.sh).";
    };
  }
