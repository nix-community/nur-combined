{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  pillow,
  django,
  coverage,
  djangorestframework,
}:
buildPythonPackage rec {
  pname = "django-colorfield";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "fabiocaccamo";
    repo = "django-colorfield";
    tag = version;
    hash = "sha256-jbUB1x0jl8rdg9eS2Ar6RXul5zW8Kh4EU+ytjoXcBpA=";
  };

  pyproject = true;
  buildInputs = [
    setuptools
  ];

  dependencies = [
    pillow
    django
  ];

  pythonImportsCheck = [
    "colorfield"
   ];

   nativeCheckInputs = [
     coverage
     djangorestframework
   ];

   checkPhase = ''
     runHook preCheck

     python runtests.py

     runHook postCheck
   '';

  meta = {
    description = "Color field for Django models with a nice color-picker in the admin";
    homepage = "https://github.com/fabiocaccamo/django-colorfield";
    changelog = "https://github.com/fabiocaccamo/django-colorfield/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
  };
}