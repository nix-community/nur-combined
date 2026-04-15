{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  click,
  hatchling,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.click-loglevel) pname version;
  pyproject = true;

  inherit (sources.click-loglevel) src;

  propagatedBuildInputs = [
    click
    hatchling
    setuptools
  ];

  pythonImportsCheck = [ "click_loglevel" ];

  meta = {
    changelog = "https://github.com/jwodder/click-loglevel/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Log level parameter type for Click";
    homepage = "https://github.com/jwodder/click-loglevel";
    license = with lib.licenses; [ mit ];
  };
}
