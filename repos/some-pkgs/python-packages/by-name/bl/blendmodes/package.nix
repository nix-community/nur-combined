{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, aenum
, deprecation
, numpy
, pillow
}:

buildPythonPackage rec {
  pname = "blendmodes";
  version = "2023";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "FHPythonUtils";
    repo = "BlendModes";
    rev = version;
    hash = "sha256-eLYd4QQbJ7t82vbbDM1hundfHZX37wkPd5Pm2hjrqQI=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    aenum
    deprecation
    numpy
    pillow
  ];

  pythonImportsCheck = [ "blendmodes" ];

  meta = with lib; {
    description = "Use this module to apply a number of blending modes to a background and foreground image";
    homepage = "https://github.com/FHPythonUtils/BlendModes";
    changelog = "https://github.com/FHPythonUtils/BlendModes/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
