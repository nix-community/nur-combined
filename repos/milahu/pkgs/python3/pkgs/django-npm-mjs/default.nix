{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, wheel
, django
, pyjson5
}:

buildPythonPackage rec {
  pname = "django-npm-mjs";
  version = "2.5.3";
  pyproject = true;

  src = fetchPypi {
    pname = "django_npm_mjs";
    inherit version;
    hash = "sha256-jMYXRN4Kq5FG+O/cFFSTPckCYe5E6VvRTC47wAtHTAs=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    django
    pyjson5
  ];

  #pythonImportsCheck = [ "django.npm_mjs" ];

  meta = {
    description = "A Django package to use npm.js dependencies and transpile ES2015";
    homepage = "https://pypi.org/project/django-npm-mjs";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
}
