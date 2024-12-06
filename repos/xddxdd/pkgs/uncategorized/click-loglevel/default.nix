{
  lib,
  sources,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  inherit (sources.click-loglevel) pname version src;
  pyproject = true;

  propagatedBuildInputs = with python3Packages; [
    click
    hatchling
    setuptools
  ];

  doCheck = false;

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Log level parameter type for Click";
    homepage = "https://github.com/jwodder/click-loglevel";
    license = with lib.licenses; [ mit ];
  };
}
