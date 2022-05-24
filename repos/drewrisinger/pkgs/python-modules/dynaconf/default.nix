{ lib
, buildPythonPackage
, fetchFromGitHub
, click
, python-box
, python-dotenv
, toml
# test inputs
, pytestCheckHook
, pytest-mock
, configobj
, django
, flask
, hvac
, vault
}:

buildPythonPackage rec {
  pname = "dynaconf";
  version = "3.1.8";

  src = fetchFromGitHub {
    owner = "rochacbruno";
    repo = pname;
    rev = version;
    sha256 = "sha256-JyexYi4btLMKxtbI4ioD+9VRg/4ormPFHoVVhDMy09s=";
  };

  propagatedBuildInputs = [
    click
    python-box
    python-dotenv
    toml
  ];

  pythonImportsCheck = [ "dynaconf" ];
  checkInputs = [
    pytestCheckHook
    pytest-mock
    configobj
    django
    flask
    hvac
    vault
  ];
  pytestFlagsArray = [
    "tests/"
    "-m 'not integration'"
  ];
  disabledTests = [
    "test_help_dont_require_instance"  # cli test expects dynaconf to be on path
  ];


  meta = with lib; {
    homepage = "https://github.com/rochacbruno/dynaconf";
    description = "The dynamic configurator for your Python Project";
    license = licenses.mit;
  };
}
