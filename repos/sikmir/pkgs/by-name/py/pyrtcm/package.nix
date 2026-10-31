{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyrtcm";
  version = "1.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyrtcm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sOqbQEp6dCFvSlk1k/h10kU+nJUX5k25RJaZG90+dGs=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ pynmeagps ];

  pythonImportsCheck = [ "pyrtcm" ];

  meta = {
    description = "RTCM3 protocol parser";
    homepage = "https://github.com/semuconsulting/pyrtcm";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
