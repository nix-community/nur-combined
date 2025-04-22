{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, wheel
}:

buildPythonPackage rec {
  pname = "django-loginas";
  version = "0.3.11";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-N67G/NHNtyN4tp0kaNKuObEs0BP4OKm/m5tRMug0FzU=";
  };

  build-system = [
    setuptools
    wheel
  ];

  #pythonImportsCheck = [ "django.loginas" ];

  meta = {
    description = ''An app to add a "Log in as user" button in the Django user admin page'';
    homepage = "https://pypi.org/project/django-loginas";
    license = with lib.licenses; [ bsd3 bsd2 ];
    maintainers = with lib.maintainers; [ ];
  };
}
