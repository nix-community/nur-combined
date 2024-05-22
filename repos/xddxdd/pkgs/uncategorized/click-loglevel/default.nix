{
  lib,
  sources,
  python3Packages,
  ...
}:
with python3Packages;
buildPythonPackage rec {
  inherit (sources.click-loglevel) pname version src;
  pyproject = true;

  propagatedBuildInputs = [
    click
    setuptools
  ];

  doCheck = false;

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Log level parameter type for Click";
    homepage = "https://github.com/jwodder/click-loglevel";
    license = with licenses; [ mit ];
  };
}
