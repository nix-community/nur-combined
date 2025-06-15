{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  setuptools,
  construct,
  gsm0338,
}:
buildPythonPackage rec {
  inherit (sources.pyosmocom) pname version src;
  pyproject = true;

  build-system = [ setuptools ];
  dependencies = [
    construct
    gsm0338
  ];

  pythonImportsCheck = [ "osmocom" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python implementation of key Osmocom protocols/interfaces";
    homepage = "https://gitea.osmocom.org/osmocom/pyosmocom";
    license = with lib.licenses; [ gpl2Only ];
  };
}
