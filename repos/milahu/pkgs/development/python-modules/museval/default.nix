{
  lib,
  python3,
  fetchFromGitHub,
  musdb,
  pandas,
  numpy,
  scipy,
  simplejson,
  soundfile,
  jsonschema,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "museval";
  version = "0.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sigsep";
    repo = "sigsep-mus-eval";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sW5QGLtsOAZWaiFiIyp99rDUrmVL7N32vFHl8zxkzKQ=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = [
    musdb
    pandas
    numpy
    scipy
    simplejson
    soundfile
    jsonschema
  ];

  pythonImportsCheck = [
    "museval"
  ];

  meta = {
    description = "Museval - source separation evaluation tools for python";
    homepage = "https://github.com/sigsep/sigsep-mus-eval";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "museval";
  };
})
