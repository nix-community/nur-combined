{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cmake,
  scikit-build,
  setuptools,
  wheel,
  numpy,
}:

buildPythonPackage (finalAttrs: {
  pname = "praat-parselmouth";
  version = "0.4.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "YannickJadoul";
    repo = "Parselmouth";
    tag = "v${finalAttrs.version}";
    # hash = "sha256-G1VrynPvy5C+ee1dYQJ1G7xWdx7W71BS4DizCcoMAFk=";
    hash = "sha256-gogNiKZVQaAzu/VeP4+bg61GtdptZeNkQatcJ/cjXFI=";
    fetchSubmodules = true;
  };

  build-system = [
    cmake
    scikit-build
    setuptools
    wheel
  ];

  dontUseCmakeConfigure = true;
  dontUseCmakeBuild = true;

  dependencies = [
    numpy
  ];

  pythonImportsCheck = [
    "parselmouth"
  ];

  meta = {
    description = "Praat in Python, the Pythonic way";
    homepage = "https://github.com/YannickJadoul/Parselmouth";
    changelog = "https://github.com/YannickJadoul/Parselmouth/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
})
