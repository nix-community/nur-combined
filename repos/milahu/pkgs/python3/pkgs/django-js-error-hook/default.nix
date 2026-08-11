{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, wheel
, django
}:

buildPythonPackage rec {
  pname = "django-js-error-hook";
  version = "1.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-iArtYV0sY8KbBPdWlg/NxbZEg+bHaTSbRNp6GpfkRXk=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    django
  ];

  pythonImportsCheck = [
    "django_js_error_hook"
  ];

  meta = {
    description = "Generic handler for hooking client side javascript error";
    homepage = "https://pypi.org/project/django-js-error-hook";
    license = with lib.licenses; [ bsd3 bsd2 ];
    maintainers = with lib.maintainers; [ ];
  };
}
