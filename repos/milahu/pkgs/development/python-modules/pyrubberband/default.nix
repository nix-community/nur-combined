{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  soundfile,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyrubberband";
  version = "0.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bmcfee";
    repo = "pyrubberband";
    tag = finalAttrs.version;
    hash = "sha256-ipmWxlFjAC37hQjcoZkOOKOErQAPV3zuEY9dmBKmcS8=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    soundfile
  ];

  pythonImportsCheck = [
    "pyrubberband"
  ];

  meta = {
    description = "Python wrapper for rubberband";
    homepage = "https://github.com/bmcfee/pyrubberband";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
  };
})
