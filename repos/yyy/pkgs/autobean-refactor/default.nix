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
    lark
    typing-extensions
  ];

  pythonImportsCheck = [ "autobean_refactor" ];

  meta = {
    description = "An ergonomic and losess beancount manipulation library";
    homepage = "https://github.com/SEIAROTg/autobean-refactor";
    license = lib.licenses.mit;
  };
}

