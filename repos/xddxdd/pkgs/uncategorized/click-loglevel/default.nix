{
  lib,
  sources,
  python3Packages,
  ...
}@args:
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
    description = "Log level parameter type for Click";
    homepage = "https://github.com/jwodder/click-loglevel";
    license = with licenses; [ mit ];
  };
}
