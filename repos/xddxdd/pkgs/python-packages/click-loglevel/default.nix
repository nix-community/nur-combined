{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  # Dependencies
  click,
  hatchling,
  nix-update-script,
  setuptools,
}:
buildPythonPackage rec {
  pname = "click-loglevel";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jwodder";
    repo = "click-loglevel";
    tag = "v0.7.0";
    hash = "sha256-Z66xy8d9KAjni4AmwZwGdHTzJHkjgO/2D+vkOhh/te8=";
  };
  propagatedBuildInputs = [
    click
    hatchling
    setuptools
  ];

  pythonImportsCheck = [ "click_loglevel" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/jwodder/click-loglevel/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Log level parameter type for Click";
    homepage = "https://github.com/jwodder/click-loglevel";
    license = with lib.licenses; [ mit ];
  };
}
