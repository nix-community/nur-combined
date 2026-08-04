{
  lib,
  buildPythonPackage,
  fetchPypi,
  django,
  django-appconf,
}:

buildPythonPackage rec {
  pname = "django-select2";
  version = "8.4.8";
  format = "wheel";

  src = fetchPypi {
    pname = "django_select2";
    inherit version format;
    dist = "py3";
    python = "py3";
    hash = "sha256-os5qTFVt0tTVfrN1NhjW8x+NORDp2fobaG2TQPULFOs=";
  };

  propagatedBuildInputs = [
    django
    django-appconf
  ];

  # Wheel-only package with no upstream test suite in the sdist we'd need.
  doCheck = false;

  pythonImportsCheck = [ "django_select2" ];

  meta = {
    description = "Django integration of Select2, not packaged in nixpkgs";
    homepage = "https://github.com/codingjoe/django-select2";
    license = lib.licenses.mit;
  };
}
