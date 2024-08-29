{ python3Packages
, generated
, lib
}:

with python3Packages;
buildPythonPackage rec {
  pyproject = true;

  inherit (generated) pname version src;

  build-system = [
    pdm-pep517
  ];

  dependencies = [
    beancount
    python-dateutil
    pyyaml
    requests
  ];

  pythonImportsCheck = [ "autobean.sorted" ];

  meta = {
    description = "A collection of plugins and scripts that help automating bookkeeping with beancount";
    homepage = "https://github.com/SEIAROTg/autobean";
    license = lib.licenses.gpl2;
  };
}

