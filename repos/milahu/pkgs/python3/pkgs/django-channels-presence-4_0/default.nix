{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, wheel
}:

buildPythonPackage rec {
  pname = "django-channels-presence-4.0";
  version = "1.1.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-K2rVKz/m3fHKGNrIZfItMUypOWo/HQHQlQhdEKqhQwY=";
  };

  build-system = [
    setuptools
    wheel
  ];

  #pythonImportsCheck = [ "django.channels_presence_4_0" ];

  meta = {
    description = "";
    homepage = "https://pypi.org/project/django-channels-presence-4_0";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
