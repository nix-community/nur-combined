{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "zhconv";
  version = "1.4.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gumblex";
    repo = "zhconv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iLhJv9V0V5NR2ZsC4RWYI69dYwb1EtmFY9+sOq1goW4=";
  };

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "zhconv"
  ];

  meta = {
    description = "Simple conversion and localization between simplified and traditional Chinese using tables from MediaWiki";
    homepage = "https://github.com/gumblex/zhconv";
    license = with lib.licenses; [
      gpl2Only
      mit
    ];
    maintainers = with lib.maintainers; [ ];
  };
})
