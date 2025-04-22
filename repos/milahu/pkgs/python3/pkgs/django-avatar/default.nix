{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, wheel
, django-appconf
, dnspython
, pillow
}:

buildPythonPackage rec {
  pname = "django-avatar";
  version = "8.0.1";
  pyproject = true;

  src = fetchPypi {
    pname = "django_avatar";
    inherit version;
    hash = "sha256-LEVQSJvgjp5f5Htsgq+roRGpwg2DlX1bZgxj6jsOtfI=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    django-appconf
    dnspython
    pillow
  ];

  #pythonImportsCheck = [ "django.avatar" ];

  meta = {
    description = "A Django app for handling user avatars";
    homepage = "https://pypi.org/project/django-avatar";
    license = with lib.licenses; [ bsd3 bsdOriginal ];
    maintainers = with lib.maintainers; [ ];
  };
}
