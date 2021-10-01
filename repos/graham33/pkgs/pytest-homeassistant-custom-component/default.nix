{ lib
, buildPythonPackage
, fetchFromGitHub
, isPy37
, isPy3k
, coverage
, homeassistant
, jsonpickle
, mock-open
, pytest
, pytest-aiohttp
, pytest-cov
, pytest-sugar
, pytest-timeout
, pytest-xdist
, pytestCheckHook
, requests-mock
, responses
, respx
, sqlalchemy
, tqdm
}:

buildPythonPackage rec {
  pname = "pytest-homeassistant-custom-component";
  version = "0.4.4";
  disabled = !isPy3k || isPy37;

  src = fetchFromGitHub {
    owner = "MatthewFlamm";
    repo = pname;
    rev = version;
    sha256 = "13szp6cjzbwb4xnf2vg7n0a5d8h92gdgnsf60flw1yjbh7mnd9nj";
  };
  postPatch = ''
    substituteInPlace requirements_test.txt \
      --replace "coverage==5.5" "coverage>=5.3" \
      --replace "homeassistant==2021.9.0b2" "homeassistant>=2021.9.0,<2021.10" \
      --replace "jsonpickle==1.4.1" "jsonpickle>=1.4.1" \
      --replace "pipdeptree==1.0.0" "" \
      --replace "pylint-strict-informational==0.1" "" \
      --replace "pytest==6.2.4" "pytest>=6.2.4" \
      --replace "pytest-test-groups==1.0.3" "" \
      --replace "pytest-xdist==2.2.1" "pytest-xdist>=2.2.1" \
      --replace "requests_mock==1.9.2" "requests_mock>=1.9.2" \
      --replace "respx==0.17.0" "respx>=0.17.0" \
      --replace "responses==0.12.0" "responses>=0.12.0" \
      --replace "sqlalchemy==1.4.17" "sqlalchemy>=1.4.17" \
      --replace "stdlib-list==0.7.0" "" \
      --replace "tqdm==4.49.0" "tqdm>=4.49.0"
  '';

  propagatedBuildInputs = [
    homeassistant
    pytest
    requests-mock
    sqlalchemy
  ];

  checkInputs = [
    coverage
    jsonpickle
    mock-open
    pytest-aiohttp
    pytest-cov
    pytest-sugar
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    responses
    respx
    tqdm
  ];

  pythonImportsCheck = [ "pytest_homeassistant_custom_component" ];

  meta = with lib; {
    homepage = "https://github.com/MatthewFlamm/pytest-homeassistant-custom-component";
    description = "Package to automatically extract testing plugins from Home Assistant for custom component testing. ";
    license = licenses.mit;
    #maintainers = with maintainers; [ graham33 ];
  };
}
